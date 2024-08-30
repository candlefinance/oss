///
/// JCode.hpp
/// Fri Aug 30 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

#pragma once

#include <fbjni/fbjni.h>
#include "Code.hpp"

namespace margelo::nitro::send {

  using namespace facebook;

  /**
   * The C++ JNI bridge between the C++ enum "Code" and the the Kotlin enum "Code".
   */
  struct JCode final: public jni::JavaClass<JCode> {
  public:
    static auto constexpr kJavaDescriptor = "Lcom/margelo/nitro/candlefinance_send/Code;";

  public:
    /**
     * Convert this Java/Kotlin-based enum to the C++ enum Code.
     */
    [[maybe_unused]]
    Code toCpp() const {
      static const auto clazz = javaClassStatic();
      static const auto fieldOrdinal = clazz->getField<int>("ordinal");
      int ordinal = this->getFieldValue(fieldOrdinal);
      return static_cast<Code>(ordinal);
    }

  public:
    /**
     * Create a Java/Kotlin-based enum with the given C++ enum's value.
     */
    [[maybe_unused]]
    static jni::alias_ref<JCode> fromCpp(Code value) {
      static const auto clazz = javaClassStatic();
      static const auto fieldRESPONSE_INVALID = clazz->getStaticField<JCode>("RESPONSE_INVALID");
      static const auto fieldREQUEST_INVALID = clazz->getStaticField<JCode>("REQUEST_INVALID");
      static const auto fieldNETWORK_ERROR = clazz->getStaticField<JCode>("NETWORK_ERROR");
      static const auto fieldNO_RESPONSE = clazz->getStaticField<JCode>("NO_RESPONSE");
      static const auto fieldNON_UTF8_RESPONSE_BODY = clazz->getStaticField<JCode>("NON_UTF8_RESPONSE_BODY");
      static const auto fieldNON_UTF8_REQUEST_BODY = clazz->getStaticField<JCode>("NON_UTF8_REQUEST_BODY");
      static const auto fieldINVALID_REQUEST_PATH_OR_QUERY_PARAMETERS = clazz->getStaticField<JCode>("INVALID_REQUEST_PATH_OR_QUERY_PARAMETERS");
      static const auto fieldINVALID_REQUEST_BASE_URL = clazz->getStaticField<JCode>("INVALID_REQUEST_BASE_URL");
      static const auto fieldNON_BASE64_REQUEST_BODY = clazz->getStaticField<JCode>("NON_BASE64_REQUEST_BODY");
      static const auto fieldINVALID_RESPONSE_HEADER_PARAMETERS = clazz->getStaticField<JCode>("INVALID_RESPONSE_HEADER_PARAMETERS");
      static const auto fieldUNEXPECTED = clazz->getStaticField<JCode>("UNEXPECTED");
      
      switch (value) {
        case Code::RESPONSE_INVALID:
          return clazz->getStaticFieldValue(fieldRESPONSE_INVALID);
        case Code::REQUEST_INVALID:
          return clazz->getStaticFieldValue(fieldREQUEST_INVALID);
        case Code::NETWORK_ERROR:
          return clazz->getStaticFieldValue(fieldNETWORK_ERROR);
        case Code::NO_RESPONSE:
          return clazz->getStaticFieldValue(fieldNO_RESPONSE);
        case Code::NON_UTF8_RESPONSE_BODY:
          return clazz->getStaticFieldValue(fieldNON_UTF8_RESPONSE_BODY);
        case Code::NON_UTF8_REQUEST_BODY:
          return clazz->getStaticFieldValue(fieldNON_UTF8_REQUEST_BODY);
        case Code::INVALID_REQUEST_PATH_OR_QUERY_PARAMETERS:
          return clazz->getStaticFieldValue(fieldINVALID_REQUEST_PATH_OR_QUERY_PARAMETERS);
        case Code::INVALID_REQUEST_BASE_URL:
          return clazz->getStaticFieldValue(fieldINVALID_REQUEST_BASE_URL);
        case Code::NON_BASE64_REQUEST_BODY:
          return clazz->getStaticFieldValue(fieldNON_BASE64_REQUEST_BODY);
        case Code::INVALID_RESPONSE_HEADER_PARAMETERS:
          return clazz->getStaticFieldValue(fieldINVALID_RESPONSE_HEADER_PARAMETERS);
        case Code::UNEXPECTED:
          return clazz->getStaticFieldValue(fieldUNEXPECTED);
        default:
          std::string stringValue = std::to_string(static_cast<int>(value));
          throw std::runtime_error("Invalid enum value (" + stringValue + "!");
      }
    }
  };

} // namespace margelo::nitro::send