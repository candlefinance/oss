package com.candlefinance.send

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.thomasbouvier.persistentcookiejar.PersistentCookieJar
import com.thomasbouvier.persistentcookiejar.cache.SetCookieCache
import com.thomasbouvier.persistentcookiejar.persistence.SharedPrefsCookiePersistor
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import okhttp3.Call
import okhttp3.Callback
import okhttp3.HttpUrl
import okhttp3.HttpUrl.Companion.toHttpUrl
import okhttp3.OkHttpClient
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.internal.http.HttpMethod
import okio.Buffer
import okio.ByteString.Companion.decodeBase64
import okio.GzipSource
import okio.IOException
import java.net.ConnectException
import java.net.ProtocolException
import java.net.SocketTimeoutException
import java.net.UnknownHostException
import java.util.concurrent.TimeUnit
import javax.net.ssl.SSLException
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

// FIXME: Move to another file or a utilities package
suspend fun Call.await(): okhttp3.Response = suspendCancellableCoroutine { continuation ->
  enqueue(object : Callback {
    override fun onFailure(call: Call, e: IOException) {
      if (continuation.isActive) continuation.resumeWithException(e)
    }

    override fun onResponse(call: Call, response: okhttp3.Response) {
      if (continuation.isActive) continuation.resume(response)
    }
  })

  continuation.invokeOnCancellation {
    cancel()
  }
}

// FIXME: Actually check charset parameter first if set, then fall back to MIME type
private fun bodyIsUTF8(contentTypeHeader: String?, utf8ContentTypes: List<String>): Boolean {
  return utf8ContentTypes.contains(contentTypeHeader?.split(';')?.firstOrNull())
}

sealed class SendException(override val message: String) : Exception() {
  object RequestBodyNotBase64 :
    SendException(message = "Your request headers specify a Content-Type NOT included in `utf8ContentTypes`, but your request body is not a base64-encoded string.")
}

@Serializable
data class Request(
  val baseURL: String,
  val path: String,
  val queryParameters: Map<String, String>,
  val headerParameters: Map<String, String>,
  val method: String,
  val body: String?,
  val utf8ContentTypes: List<String>,
) {
  val httpUrl: HttpUrl by lazy {
    val urlBuilder = (baseURL + path).toHttpUrl().newBuilder()
    queryParameters.forEach { (key, value) ->
      urlBuilder.addEncodedQueryParameter(key, value)
    }

    urlBuilder.build()
  }

  val okHttpRequest: okhttp3.Request by lazy {
    val requestBuilder = okhttp3.Request.Builder().url(httpUrl)
    headerParameters.forEach { (key, value) ->
      requestBuilder.addHeader(key, value)
    }

    requestBuilder.method(
      method,
      if (body == null) if (HttpMethod.requiresRequestBody(method)) "".toRequestBody() else null
      else {
        val contentTypeHeader = headerParameters.entries.find {
          it.key.equals(
            "content-type", ignoreCase = true
          )
        }?.value
        if (bodyIsUTF8(
            contentTypeHeader, utf8ContentTypes
          )
        ) body.toRequestBody()
        else body.decodeBase64()?.toRequestBody() ?: throw SendException.RequestBodyNotBase64
      }
    )

    requestBuilder.build()
  }
}

@Serializable
data class Response(
  val statusCode: Int,
  val headerParameters: Map<String, String>,
  val body: String?,
) {

  constructor(
    request: Request, okHttpResponse: okhttp3.Response
  ) : this(statusCode = okHttpResponse.code,
    headerParameters = okHttpResponse.headers.names()
      .associateWith { okHttpResponse.headers(it).last() },

    body = okHttpResponse.body?.let { responseBody ->
      val bodyIsGzipped = okHttpResponse.headers.values("content-encoding")
        .let { if (it.isEmpty()) null else it.last() } == "gzip"
      val bodyIsUTF8 = bodyIsUTF8(
        okHttpResponse.headers.values("content-type").let { if (it.isEmpty()) null else it.last() },
        request.utf8ContentTypes
      )

      if (bodyIsGzipped) {
        val gzipSource = GzipSource(responseBody.source())
        val buffer = Buffer()
        buffer.writeAll(gzipSource)
        gzipSource.close()
        if (bodyIsUTF8) buffer.readUtf8() else buffer.readByteString().base64()
      } else {
        if (bodyIsUTF8) responseBody.string() else responseBody.byteString().base64()
      }
    })
}

class SendModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
  private val cookieManager by lazy { PersistentCookieJar(SetCookieCache(), SharedPrefsCookiePersistor(reactContext)) }

  private val client by lazy {
    OkHttpClient.Builder()
      .callTimeout(60, TimeUnit.SECONDS)
      .connectTimeout(0, TimeUnit.SECONDS)
      .readTimeout(0, TimeUnit.SECONDS)
      .writeTimeout(0, TimeUnit.SECONDS)
      .cookieJar(cookieManager)
      .followRedirects(false) // NOTE: This implicitly sets followSslRedirects(false) as well
      .build()
  }

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun send(stringifiedRequest: String, promise: Promise) {
    CoroutineScope(Dispatchers.Unconfined).launch {
      try {
        val request = try {
          Json.decodeFromString<Request>(stringifiedRequest)
        } catch (e: SerializationException) {
          return@launch promise.reject(CODE_REQUEST_INVALID, e.message, e)
        }

        val okHttpRequest = try {
          request.okHttpRequest
        } catch (e: SendException) {
          return@launch when (e) {
            is SendException.RequestBodyNotBase64 -> promise.reject(
              CODE_REQUEST_INVALID, e.message, e
            )
          }
        } catch (e: Exception) {
          return@launch promise.reject(CODE_REQUEST_INVALID, MESSAGE_REQUEST_INVALID, e)
        }

        val okHttpResponse = try {
          client.newCall(okHttpRequest).await()
        } catch (e: IOException) {
          return@launch when (e) {
            is UnknownHostException -> promise.reject(
              CODE_REQUEST_INVALID, MESSAGE_REQUEST_INVALID, e
            )

            is SocketTimeoutException, is SSLException, is ConnectException, is ProtocolException -> promise.reject(
              CODE_NO_RESPONSE, MESSAGE_NO_RESPONSE, e
            )

            else -> promise.reject(
              CODE_RESPONSE_INVALID, MESSAGE_RESPONSE_INVALID, e
            )
          }
        }

        val response = try {
          Response(request, okHttpResponse)
        } catch (e: Exception) {
          return@launch promise.reject(CODE_RESPONSE_INVALID, MESSAGE_RESPONSE_INVALID, e)
        }

        val stringifiedResponse = try {
          Json.encodeToString(response)
        } catch (e: SerializationException) {
          return@launch promise.reject(CODE_RESPONSE_INVALID, e.message, e)
        }

        promise.resolve(stringifiedResponse)
      } catch (e: Exception) {
        promise.reject(CODE_UNKNOWN, MESSAGE_UNKNOWN, e)
      }
    }
  }

  companion object {
    const val NAME = "Send"
    const val CODE_REQUEST_INVALID = "@candlefinance.send.request_invalid"
    const val CODE_NO_RESPONSE = "@candlefinance.send.no_response"
    const val CODE_RESPONSE_INVALID = "@candlefinance.send.response_invalid"
    const val CODE_UNKNOWN = "@candlefinance.send.unknown"

    const val MESSAGE_REQUEST_INVALID =
      "Your request is invalid. Please verify the format of your base URL and any other fields specified."
    const val MESSAGE_NO_RESPONSE =
      "Your request did not receive a response. Please verify your Internet connection."
    const val MESSAGE_RESPONSE_INVALID =
      "Your request received a response, but it couldn't be processed. Please verify the configuration of your server."
    const val MESSAGE_UNKNOWN = "Something went wrong. Please file an issue on GitHub or try again."
  }
}
