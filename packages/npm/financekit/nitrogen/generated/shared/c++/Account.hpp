///
/// Account.hpp
/// Sat Aug 31 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

#pragma once

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



#include <string>

namespace margelo::nitro::financekit {

  /**
   * A struct which can be represented as a JavaScript object (Account).
   */
  struct Account {
  public:
    std::string id     SWIFT_PRIVATE;
    std::string displayName     SWIFT_PRIVATE;
    std::string accountDescription     SWIFT_PRIVATE;
    std::string institutionName     SWIFT_PRIVATE;
    std::string currencyCode     SWIFT_PRIVATE;

  public:
    explicit Account(std::string id, std::string displayName, std::string accountDescription, std::string institutionName, std::string currencyCode): id(id), displayName(displayName), accountDescription(accountDescription), institutionName(institutionName), currencyCode(currencyCode) {}
  };

} // namespace margelo::nitro::financekit

namespace margelo::nitro {

  using namespace margelo::nitro::financekit;

  // C++ Account <> JS Account (object)
  template <>
  struct JSIConverter<Account> {
    static inline Account fromJSI(jsi::Runtime& runtime, const jsi::Value& arg) {
      jsi::Object obj = arg.asObject(runtime);
      return Account(
        JSIConverter<std::string>::fromJSI(runtime, obj.getProperty(runtime, "id")),
        JSIConverter<std::string>::fromJSI(runtime, obj.getProperty(runtime, "displayName")),
        JSIConverter<std::string>::fromJSI(runtime, obj.getProperty(runtime, "accountDescription")),
        JSIConverter<std::string>::fromJSI(runtime, obj.getProperty(runtime, "institutionName")),
        JSIConverter<std::string>::fromJSI(runtime, obj.getProperty(runtime, "currencyCode"))
      );
    }
    static inline jsi::Value toJSI(jsi::Runtime& runtime, const Account& arg) {
      jsi::Object obj(runtime);
      obj.setProperty(runtime, "id", JSIConverter<std::string>::toJSI(runtime, arg.id));
      obj.setProperty(runtime, "displayName", JSIConverter<std::string>::toJSI(runtime, arg.displayName));
      obj.setProperty(runtime, "accountDescription", JSIConverter<std::string>::toJSI(runtime, arg.accountDescription));
      obj.setProperty(runtime, "institutionName", JSIConverter<std::string>::toJSI(runtime, arg.institutionName));
      obj.setProperty(runtime, "currencyCode", JSIConverter<std::string>::toJSI(runtime, arg.currencyCode));
      return obj;
    }
    static inline bool canConvert(jsi::Runtime& runtime, const jsi::Value& value) {
      if (!value.isObject()) {
        return false;
      }
      jsi::Object obj = value.getObject(runtime);
      if (!JSIConverter<std::string>::canConvert(runtime, obj.getProperty(runtime, "id"))) return false;
      if (!JSIConverter<std::string>::canConvert(runtime, obj.getProperty(runtime, "displayName"))) return false;
      if (!JSIConverter<std::string>::canConvert(runtime, obj.getProperty(runtime, "accountDescription"))) return false;
      if (!JSIConverter<std::string>::canConvert(runtime, obj.getProperty(runtime, "institutionName"))) return false;
      if (!JSIConverter<std::string>::canConvert(runtime, obj.getProperty(runtime, "currencyCode"))) return false;
      return true;
    }
  };

} // namespace margelo::nitro
