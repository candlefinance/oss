///
/// JSendParameters.hpp
/// Mon Sep 02 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

#pragma once

#include <fbjni/fbjni.h>
#include "SendParameters.hpp"

#include <string>
#include <unordered_map>

namespace margelo::nitro::send {

  using namespace facebook;

  /**
   * The C++ JNI bridge between the C++ struct "SendParameters" and the the Kotlin data class "SendParameters".
   */
  struct JSendParameters final: public jni::JavaClass<JSendParameters> {
  public:
    static auto constexpr kJavaDescriptor = "Lcom/margelo/nitro/candlefinance_send/SendParameters;";

  public:
    /**
     * Convert this Java/Kotlin-based struct to the C++ struct SendParameters by copying all values to C++.
     */
    [[maybe_unused]]
    SendParameters toCpp() const {
      static const auto clazz = javaClassStatic();
      static const auto fieldParameters = clazz->getField<jni::JMap<jni::JString, jni::JString>>("parameters");
      jni::local_ref<jni::JMap<jni::JString, jni::JString>> parameters = this->getFieldValue(fieldParameters);
      return SendParameters(
        [&]() {
          std::unordered_map<std::string, std::string> map;
          map.reserve(parameters->size());
          for (const auto& entry : *parameters) {
            map.emplace(entry.first->toStdString(), entry.second->toStdString());
          }
          return map;
        }()
      );
    }

  public:
    /**
     * Create a Java/Kotlin-based struct by copying all values from the given C++ struct to Java.
     */
    [[maybe_unused]]
    static jni::local_ref<JSendParameters::javaobject> fromCpp(const SendParameters& value) {
      return newInstance(
        [&]() {
          auto map = jni::JHashMap<jni::JString, jni::JString>::create(value.parameters.size());
          for (const auto& entry : value.parameters) {
            map->put(jni::make_jstring(entry.first), jni::make_jstring(entry.second));
          }
          return map;
        }()
      );
    }
  };

} // namespace margelo::nitro::send
