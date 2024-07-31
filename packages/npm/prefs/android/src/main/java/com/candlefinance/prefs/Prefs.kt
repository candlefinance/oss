package com.candlefinance.prefs

import android.content.SharedPreferences
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class PrefsModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
  private val sharedPreferences: SharedPreferences = reactContext.getSharedPreferences("foo", 0)
  override fun getName(): String = "Prefs"

  @ReactMethod
  fun getPref(key: String, promise: Promise) {
    promise.resolve(sharedPreferences.getString(key, null))
  }

  // FIXME: Use stringifiedParams like in Financekit
  @ReactMethod
  fun setPref(key: String, value: String, promise: Promise) {
    with(sharedPreferences.edit()) {
      putString(key, value)
      apply()
    }
    promise.resolve(null)
  }

  @ReactMethod
  fun deletePref(key: String, promise: Promise) {
    with(sharedPreferences.edit()) {
      remove(key)
      apply()
    }
    promise.resolve(null)
  }
}
