package com.candlefinance.send
import java.net.CookieStore
import java.net.HttpCookie
import java.net.URI
import android.content.Context
import android.content.SharedPreferences
class PersistentCookieStore(context: Context) : CookieStore {
  private val prefs: SharedPreferences = context.getSharedPreferences("cookies", Context.MODE_PRIVATE)
  private val cookies: MutableMap<String, HttpCookie> = mutableMapOf()
  init {
    prefs.all.forEach { (key, value) ->
      val cookie = HttpCookie.parse(value as String).first()
      cookies[key] = cookie
    }
  }
  override fun add(uri: URI, cookie: HttpCookie) {
    cookies[cookie.name] = cookie
    prefs.edit().putString(cookie.name, cookie.toString()).apply()
  }
  override fun get(uri: URI): List<HttpCookie> {
    return cookies.values.toList()
  }

  override fun getCookies(): MutableList<HttpCookie> {
    return cookies.values.toMutableList()
  }

  override fun getURIs(): MutableList<URI> {
    return cookies.keys.map { URI.create(it) }.toMutableList()
  }

  override fun remove(uri: URI, cookie: HttpCookie): Boolean {
    return cookies.remove(cookie.name) != null
  }
  override fun removeAll(): Boolean {
    cookies.clear()
    prefs.edit().clear().apply()
    return true
  }
}
