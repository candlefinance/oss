///
/// JMethod.hpp
/// Fri Aug 30 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

#pragma once

#include <fbjni/fbjni.h>
#include "Method.hpp"

namespace margelo::nitro::send {

  using namespace facebook;

  /**
   * The C++ JNI bridge between the C++ enum "Method" and the the Kotlin enum "Method".
   */
  struct JMethod final: public jni::JavaClass<JMethod> {
  public:
    static auto constexpr kJavaDescriptor = "Lcom/margelo/nitro/candlefinance_send/Method;";

  public:
    /**
     * Convert this Java/Kotlin-based enum to the C++ enum Method.
     */
    [[maybe_unused]]
    Method toCpp() const {
      static const auto clazz = javaClassStatic();
      static const auto fieldOrdinal = clazz->getField<int>("ordinal");
      int ordinal = this->getFieldValue(fieldOrdinal);
      return static_cast<Method>(ordinal);
    }

  public:
    /**
     * Create a Java/Kotlin-based enum with the given C++ enum's value.
     */
    [[maybe_unused]]
    static jni::alias_ref<JMethod> fromCpp(Method value) {
      static const auto clazz = javaClassStatic();
      static const auto fieldGET = clazz->getStaticField<JMethod>("GET");
      static const auto fieldPOST = clazz->getStaticField<JMethod>("POST");
      static const auto fieldPUT = clazz->getStaticField<JMethod>("PUT");
      static const auto fieldDELETE = clazz->getStaticField<JMethod>("DELETE");
      static const auto fieldPATCH = clazz->getStaticField<JMethod>("PATCH");
      static const auto fieldHEAD = clazz->getStaticField<JMethod>("HEAD");
      static const auto fieldOPTIONS = clazz->getStaticField<JMethod>("OPTIONS");
      static const auto fieldCONNECT = clazz->getStaticField<JMethod>("CONNECT");
      static const auto fieldTRACE = clazz->getStaticField<JMethod>("TRACE");
      
      switch (value) {
        case Method::GET:
          return clazz->getStaticFieldValue(fieldGET);
        case Method::POST:
          return clazz->getStaticFieldValue(fieldPOST);
        case Method::PUT:
          return clazz->getStaticFieldValue(fieldPUT);
        case Method::DELETE:
          return clazz->getStaticFieldValue(fieldDELETE);
        case Method::PATCH:
          return clazz->getStaticFieldValue(fieldPATCH);
        case Method::HEAD:
          return clazz->getStaticFieldValue(fieldHEAD);
        case Method::OPTIONS:
          return clazz->getStaticFieldValue(fieldOPTIONS);
        case Method::CONNECT:
          return clazz->getStaticFieldValue(fieldCONNECT);
        case Method::TRACE:
          return clazz->getStaticFieldValue(fieldTRACE);
        default:
          std::string stringValue = std::to_string(static_cast<int>(value));
          throw std::runtime_error("Invalid enum value (" + stringValue + "!");
      }
    }
  };

} // namespace margelo::nitro::send