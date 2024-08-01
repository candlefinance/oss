package com.candlefinance.prefs

import android.content.Context
import android.content.SharedPreferences
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class PrefsModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
  private val sharedPreferences: SharedPreferences =
    reactContext.getSharedPreferences("com.candlefinance.prefs", Context.MODE_PRIVATE)

  override fun getName(): String = NAME

  @ReactMethod
  fun getPref(key: String, promise: Promise) {
    try {
      promise.resolve(sharedPreferences.getString(key, null))
    } catch (e: ClassCastException) {
      promise.reject(
        CODE_NON_STRING_VALUE, MESSAGE_NON_STRING_VALUE, e
      )
    } catch (e: Exception) {
      promise.reject(
        CODE_UNEXPECTED, MESSAGE_UNEXPECTED, e
      )
    }
  }

  // FIXME: Use stringifiedParams like in Financekit
  @ReactMethod
  fun setPref(key: String, value: String, promise: Promise) {
    try {
      val commitSucceeded = with(sharedPreferences.edit()) {
        putString(key, value)
        commit()
      }
      if (commitSucceeded) {
        promise.resolve(null)
      } else {
        promise.reject(
          CODE_EDIT_COMMIT_FAILED, MESSAGE_EDIT_COMMIT_FAILED, Exception()
        )
      }
    } catch (e: Exception) {
      promise.reject(
        CODE_UNEXPECTED, MESSAGE_UNEXPECTED, e
      )
    }
  }

  @ReactMethod
  fun deletePref(key: String, promise: Promise) {
    try {
      val commitSucceeded = with(sharedPreferences.edit()) {
        remove(key)
        commit()
      }
      if (commitSucceeded) {
        promise.resolve(null)
      } else {
        promise.reject(
          CODE_EDIT_COMMIT_FAILED, MESSAGE_EDIT_COMMIT_FAILED, Exception()
        )
      }
    } catch (e: Exception) {
      promise.reject(
        CODE_UNEXPECTED, MESSAGE_UNEXPECTED, e
      )
    }
  }

  companion object {
    const val NAME = "Prefs"

    const val CODE_EDIT_COMMIT_FAILED = "@candlefinance.prefs.edit_commit_failed"
    const val CODE_NON_STRING_VALUE = "@candlefinance.prefs.non_string_value"
    const val CODE_UNEXPECTED = "@candlefinance.prefs.unexpected"

    const val MESSAGE_EDIT_COMMIT_FAILED =
      "SharedPreferences edit could not be committed. Please file an issue on GitHub or try again."
    const val MESSAGE_NON_STRING_VALUE =
      "SharedPreferences value was found, but is not a string. You can use deletePref() to remove the existing value and try again. If you're setting this value from native Android code, make sure to use putString()."
    const val MESSAGE_UNEXPECTED =
      "Something went wrong. Please file an issue on GitHub or try again."
  }
}
