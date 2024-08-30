///
/// HybridSendSpec.kt
/// Fri Aug 30 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

package com.margelo.nitro.candlefinance_send

import android.util.Log
import androidx.annotation.Keep
import com.facebook.jni.HybridData
import com.facebook.proguard.annotations.DoNotStrip
import com.margelo.nitro.core.*

/**
 * A Kotlin class representing the Send HybridObject.
 * Implement this abstract class to create Kotlin-based instances of Send.
 */
@DoNotStrip
@Keep
@Suppress("RedundantSuppression", "KotlinJniMissingFunction", "PropertyName", "RedundantUnitReturnType", "unused")
abstract class HybridSendSpec: HybridObject() {
  protected val TAG = "HybridSendSpec"

  @DoNotStrip
  val mHybridData: HybridData = initHybrid()

  init {
    // Pass this `HybridData` through to it's base class,
    // to represent inheritance to JHybridObject on C++ side
    super.updateNative(mHybridData)
  }

  // Properties
  

  // Methods
  @DoNotStrip
  @Keep
  abstract fun send(request: Request): Promise<SendResult>

  private external fun initHybrid(): HybridData

  companion object {
    private const val TAG = "HybridSendSpec"
    init {
      try {
        Log.i(TAG, "Loading send C++ library...")
        System.loadLibrary("send")
        Log.i(TAG, "Successfully loaded send C++ library!")
      } catch (e: Error) {
        Log.e(TAG, "Failed to load send C++ library! Is it properly installed and linked? " +
                    "Is the name correct? (see `CMakeLists.txt`, at `add_library(...)`)", e)
        throw e
      }
    }
  }
}
