@file:Suppress("UNUSED_PARAMETER", "unused")

package com.candlefinance.financekit

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise

class Financekit(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
  override fun getName(): String = "FinanceKit"
  private fun Promise.rejectionStub() = reject("@candlefinance.financekit.android_not_supported", "This method is not supported on Android", Exception())

  @ReactMethod
  fun requestAuthorization(promise: Promise) = promise.resolve("denied")

  @ReactMethod
  fun authorizationStatus(promise: Promise) = promise.resolve("denied")

  @ReactMethod
  fun transactionsWithStringifiedQuery(stringifiedQuery: String, promise: Promise) = promise.rejectionStub()

  @ReactMethod
  fun transactionHistory(stringifiedParams: String, promise: Promise) = promise.rejectionStub()

  @ReactMethod
  fun accountsWithStringifiedQuery(stringifiedQuery: String, promise: Promise) = promise.rejectionStub()

  @ReactMethod
  fun accountHistory(stringifiedParams: String, promise: Promise) = promise.rejectionStub()

  @ReactMethod
  fun accountBalancesWithStringifiedQuery(stringifiedQuery: String, promise: Promise) = promise.rejectionStub()

  @ReactMethod
  fun accountBalanceHistory(stringifiedParams: String, promise: Promise) = promise.rejectionStub()
}
