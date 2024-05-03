package com.candlefinance.send

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import okhttp3.HttpUrl
import okhttp3.HttpUrl.Companion.toHttpUrl
import okhttp3.OkHttpClient
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.internal.http.HttpMethod
import okio.Buffer
import okio.ByteString.Companion.decodeBase64
import okio.GzipSource
import okio.IOException
import java.util.concurrent.TimeUnit

// FIXME: Actually check charset parameter first if set, then fall back to MIME type
private fun bodyIsUTF8(contentTypeHeader: String?, utf8ContentTypes: List<String>): Boolean {
  return contentTypeHeader != null && utf8ContentTypes.contains(contentTypeHeader.split(';')[0])
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
  val httpUrl: HttpUrl
    get() {
      val urlBuilder = (baseURL + path).toHttpUrl().newBuilder()
      queryParameters.forEach { (key, value) ->
        urlBuilder.addQueryParameter(key, value)
      }

      return urlBuilder.build()
    }

  val okHttpRequest: okhttp3.Request
    get() {
      val requestBuilder = okhttp3.Request.Builder().url(httpUrl)
      headerParameters.forEach { (key, value) ->
        requestBuilder.addHeader(key, value)
      }

      requestBuilder.method(
        method,
        if (body == null)
          if (HttpMethod.requiresRequestBody(method)) "".toRequestBody() else null
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
          else body.decodeBase64()!!.toRequestBody()
        }
      )

      return requestBuilder.build()
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

  private val client by lazy {
    OkHttpClient.Builder()
      .callTimeout(60, TimeUnit.SECONDS)
      .connectTimeout(0, TimeUnit.SECONDS)
      .readTimeout(0, TimeUnit.SECONDS)
      .writeTimeout(0, TimeUnit.SECONDS)
      .followRedirects(false) // NOTE: This implicitly sets followSslRedirects(false) as well
      .build()
  }

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun send(stringifiedRequest: String, promise: Promise) {
//    CoroutineScope(Dispatchers.IO).launch {
    try {
      val request: Request
      try {
        request = Json.decodeFromString<Request>(stringifiedRequest)
      } catch (serializationException: SerializationException) {
        promise.reject(
          "@candlefinance.send.stringified_request_invalid",
          serializationException.message,
          serializationException
        )
        return
      }

      val okHttpResponse: okhttp3.Response
      try {
        okHttpResponse = client.newCall(request.okHttpRequest).execute()
      } catch (ioException: IOException) {
        // FIXME: switch on error and reject promise
        return
      }
      val response = Response(request, okHttpResponse)

      try {
        promise.resolve(Json.encodeToString(response))
      } catch (serializationException: SerializationException) {
        promise.reject(
          "@candlefinance.send.response_invalid", RESPONSE_ERROR, serializationException
        )
      }
    } catch (exception: Exception) {
      promise.reject("@candlefinance.send.unknown", UNKNOWN_ERROR, exception)
    }
//    }
  }

  companion object {
    const val NAME = "Send"
    const val REQUEST_ERROR =
      "Your request was invalid. Please make sure it conforms to the Request type and try again."
    const val SERVER_ERROR =
      "Your request did not receive a response. Please make sure you are connected to the Internet and try again."
    const val RESPONSE_ERROR =
      "Your request received a response, but it couldn't be processed. Please file an issue on GitHub or try again."
    const val UNKNOWN_ERROR = "Something went wrong. Please file an issue on GitHub or try again."
  }
}
