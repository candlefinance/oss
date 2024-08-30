///
/// Code.hpp
/// Fri Aug 30 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

#pragma once

#include <cmath>
#if __has_include(<NitroModules/JSIConverter.hpp>)
#include <NitroModules/JSIConverter.hpp>
#else
#error NitroModules cannot be found! Are you sure you installed NitroModules properly?
#endif
#if __has_include(<NitroModules/NitroDefines.hpp>)
#include <NitroModules/NitroDefines.hpp>
#else
#error NitroModules cannot be found! Are you sure you installed NitroModules properly?
#endif

namespace margelo::nitro::send {

  /**
   * An enum which can be represented as a JavaScript enum (Code).
   */
  enum class Code {
    RESPONSE_INVALID      SWIFT_NAME(responseInvalid) = 0,
    REQUEST_INVALID      SWIFT_NAME(requestInvalid) = 1,
    NETWORK_ERROR      SWIFT_NAME(networkError) = 2,
    NO_RESPONSE      SWIFT_NAME(noResponse) = 3,
    NON_UTF8_RESPONSE_BODY      SWIFT_NAME(nonUtf8ResponseBody) = 4,
    NON_UTF8_REQUEST_BODY      SWIFT_NAME(nonUtf8RequestBody) = 5,
    INVALID_REQUEST_PATH_OR_QUERY_PARAMETERS      SWIFT_NAME(invalidRequestPathOrQueryParameters) = 6,
    INVALID_REQUEST_BASE_URL      SWIFT_NAME(invalidRequestBaseUrl) = 7,
    NON_BASE64_REQUEST_BODY      SWIFT_NAME(nonBase64RequestBody) = 8,
    INVALID_RESPONSE_HEADER_PARAMETERS      SWIFT_NAME(invalidResponseHeaderParameters) = 9,
    UNEXPECTED      SWIFT_NAME(unexpected) = 10,
  } CLOSED_ENUM;

} // namespace margelo::nitro::send

namespace margelo::nitro {

  using namespace margelo::nitro::send;

  // C++ Code <> JS Code (enum)
  template <>
  struct JSIConverter<Code> {
    static inline Code fromJSI(jsi::Runtime& runtime, const jsi::Value& arg) {
      int enumValue = JSIConverter<int>::fromJSI(runtime, arg);
      return static_cast<Code>(enumValue);
    }
    static inline jsi::Value toJSI(jsi::Runtime& runtime, Code arg) {
      int enumValue = static_cast<int>(arg);
      return JSIConverter<int>::toJSI(runtime, enumValue);
    }
    static inline bool canConvert(jsi::Runtime& runtime, const jsi::Value& value) {
      if (!value.isNumber()) {
        return false;
      }
      double integer;
      double fraction = modf(value.getNumber(), &integer);
      if (fraction != 0.0) {
        // It is some kind of floating point number - our enums are ints.
        return false;
      }
      // Check if we are within the bounds of the enum.
      return integer >= 0 && integer <= 10;
    }
  };

} // namespace margelo::nitro