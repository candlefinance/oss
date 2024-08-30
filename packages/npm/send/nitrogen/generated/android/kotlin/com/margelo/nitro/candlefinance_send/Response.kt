///
/// Response.kt
/// Fri Aug 30 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

package com.margelo.nitro.candlefinance_send

import androidx.annotation.Keep
import com.facebook.proguard.annotations.DoNotStrip

/**
 * Represents the JavaScript object/struct "Response".
 */
@DoNotStrip
@Keep
data class Response(
  val statusCode: Double,
  val header: Parameters,
  val body: String?
)