@file:Suppress("UNUSED_PARAMETER", "unused")

package com.candlefinance.financekit

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise

class FinancekitModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
  override fun getName(): String = NAME

  @ReactMethod
  fun requestAuthorization(promise: Promise) = promise.resolve(AUTHORIZATION_STATUS_DENIED)

  @ReactMethod
  fun authorizationStatus(promise: Promise) = promise.resolve(AUTHORIZATION_STATUS_DENIED)

  @ReactMethod
  fun transactions(stringifiedQuery: String, promise: Promise) = promise.reject(
    CODE_ANDROID_NOT_SUPPORTED, MESSAGE_ANDROID_NOT_SUPPORTED, Exception()
  )

  @ReactMethod
  fun transactionHistory(stringifiedParams: String, promise: Promise) = promise.reject(
    CODE_ANDROID_NOT_SUPPORTED, MESSAGE_ANDROID_NOT_SUPPORTED, Exception()
  )

  @ReactMethod
  fun accounts(stringifiedQuery: String, promise: Promise) = promise.reject(
    CODE_ANDROID_NOT_SUPPORTED, MESSAGE_ANDROID_NOT_SUPPORTED, Exception()
  )

  @ReactMethod
  fun accountHistory(stringifiedParams: String, promise: Promise) = promise.reject(
    CODE_ANDROID_NOT_SUPPORTED, MESSAGE_ANDROID_NOT_SUPPORTED, Exception()
  )

  @ReactMethod
  fun accountBalances(stringifiedQuery: String, promise: Promise) = promise.reject(
    CODE_ANDROID_NOT_SUPPORTED, MESSAGE_ANDROID_NOT_SUPPORTED, Exception()
  )

  @ReactMethod
  fun accountBalanceHistory(stringifiedParams: String, promise: Promise) = promise.reject(
    CODE_ANDROID_NOT_SUPPORTED, MESSAGE_ANDROID_NOT_SUPPORTED, Exception()
  )

  companion object {
    const val NAME = "Financekit"

    const val AUTHORIZATION_STATUS_DENIED = "denied"

    const val CODE_ANDROID_NOT_SUPPORTED = "@candlefinance.financekit.android_not_supported"
    const val MESSAGE_ANDROID_NOT_SUPPORTED = "This method is not supported on Android"
  }
}
