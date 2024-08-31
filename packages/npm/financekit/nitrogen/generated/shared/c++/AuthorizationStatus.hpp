///
/// AuthorizationStatus.hpp
/// Sat Aug 31 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

#pragma once

#if __has_include(<NitroModules/NitroHash.hpp>)
#include <NitroModules/NitroHash.hpp>
#else
#error NitroModules cannot be found! Are you sure you installed NitroModules properly?
#endif
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

namespace margelo::nitro::financekit {

  /**
   * An enum which can be represented as a JavaScript union (AuthorizationStatus).
   */
  enum class AuthorizationStatus {
    AUTHORIZED      SWIFT_NAME(authorized) = 0,
    DENIED      SWIFT_NAME(denied) = 1,
    NOTDETERMINED      SWIFT_NAME(notdetermined) = 2,
  } CLOSED_ENUM;

} // namespace margelo::nitro::financekit

namespace margelo::nitro {

  using namespace margelo::nitro::financekit;

  // C++ AuthorizationStatus <> JS AuthorizationStatus (union)
  template <>
  struct JSIConverter<AuthorizationStatus> {
    static inline AuthorizationStatus fromJSI(jsi::Runtime& runtime, const jsi::Value& arg) {
      std::string unionValue = JSIConverter<std::string>::fromJSI(runtime, arg);
      switch (hashString(unionValue.c_str(), unionValue.size())) {
        case hashString("authorized"): return AuthorizationStatus::AUTHORIZED;
        case hashString("denied"): return AuthorizationStatus::DENIED;
        case hashString("notDetermined"): return AuthorizationStatus::NOTDETERMINED;
        default: [[unlikely]]
          throw std::runtime_error("Cannot convert \"" + unionValue + "\" to enum AuthorizationStatus - invalid value!");
      }
    }
    static inline jsi::Value toJSI(jsi::Runtime& runtime, AuthorizationStatus arg) {
      switch (arg) {
        case AuthorizationStatus::AUTHORIZED: return JSIConverter<std::string>::toJSI(runtime, "authorized");
        case AuthorizationStatus::DENIED: return JSIConverter<std::string>::toJSI(runtime, "denied");
        case AuthorizationStatus::NOTDETERMINED: return JSIConverter<std::string>::toJSI(runtime, "notDetermined");
        default: [[unlikely]]
          throw std::runtime_error("Cannot convert AuthorizationStatus to JS - invalid value: "
                                    + std::to_string(static_cast<int>(arg)) + "!");
      }
    }
    static inline bool canConvert(jsi::Runtime& runtime, const jsi::Value& value) {
      if (!value.isString()) {
        return false;
      }
      std::string unionValue = JSIConverter<std::string>::fromJSI(runtime, value);
      switch (hashString(unionValue.c_str(), unionValue.size())) {
        case hashString("authorized"):
        case hashString("denied"):
        case hashString("notDetermined"):
          return true;
        default:
          return false;
      }
    }
  };

} // namespace margelo::nitro
