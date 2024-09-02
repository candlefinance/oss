///
/// SendParameters.kt
/// Mon Sep 02 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

package com.margelo.nitro.candlefinance_send

import androidx.annotation.Keep
import com.facebook.proguard.annotations.DoNotStrip

/**
 * Represents the JavaScript object/struct "SendParameters".
 */
@DoNotStrip
@Keep
data class SendParameters(
  val parameters: Map<String, String>
)