///
/// JSendResponse.hpp
/// Mon Sep 02 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

#pragma once

#include <fbjni/fbjni.h>
#include "SendResponse.hpp"

#include "JSendParameters.hpp"
#include "SendParameters.hpp"
#include <optional>
#include <string>
#include <unordered_map>

namespace margelo::nitro::send {

  using namespace facebook;

  /**
   * The C++ JNI bridge between the C++ struct "SendResponse" and the the Kotlin data class "SendResponse".
   */
  struct JSendResponse final: public jni::JavaClass<JSendResponse> {
  public:
    static auto constexpr kJavaDescriptor = "Lcom/margelo/nitro/candlefinance_send/SendResponse;";

  public:
    /**
     * Convert this Java/Kotlin-based struct to the C++ struct SendResponse by copying all values to C++.
     */
    [[maybe_unused]]
    SendResponse toCpp() const {
      static const auto clazz = javaClassStatic();
      static const auto fieldStatusCode = clazz->getField<double>("statusCode");
      double statusCode = this->getFieldValue(fieldStatusCode);
      static const auto fieldHeader = clazz->getField<JSendParameters>("header");
      jni::local_ref<JSendParameters> header = this->getFieldValue(fieldHeader);
      static const auto fieldBody = clazz->getField<jni::JString>("body");
      jni::local_ref<jni::JString> body = this->getFieldValue(fieldBody);
      return SendResponse(
        statusCode,
        header->toCpp(),
        body != nullptr ? std::make_optional(body->toStdString()) : std::nullopt
      );
    }

  public:
    /**
     * Create a Java/Kotlin-based struct by copying all values from the given C++ struct to Java.
     */
    [[maybe_unused]]
    static jni::local_ref<JSendResponse::javaobject> fromCpp(const SendResponse& value) {
      return newInstance(
        value.statusCode,
        JSendParameters::fromCpp(value.header),
        value.body.has_value() ? jni::make_jstring(value.body.value()) : nullptr
      );
    }
  };

} // namespace margelo::nitro::send
