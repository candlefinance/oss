package com.candlefinance.prefs

import android.content.SharedPreferences
import androidx.core.content.edit
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class Prefs(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
  private val sharedPreferences: SharedPreferences = reactContext.getSharedPreferences("foo", 0)
  override fun getName(): String = "Prefs"

  @ReactMethod  
  fun getString(key: String, promise: Promise) { promise.resolve(sharedPreferences.getString(key, null)) }

  // FIXME: Use stringifiedParams like in Financekit
  @ReactMethod
  fun setString(key: String, value: String, promise: Promise) {
    with (sharedPreferences.edit()) {
      putString(key, value)
      apply()
    }
    promise.resolve(null)
  }

  @ReactMethod
  fun deleteString(key: String, promise: Promise) {
    with (sharedPreferences.edit()) {
      remove(key)
      apply()
    }
    promise.resolve(null)
  }
}
