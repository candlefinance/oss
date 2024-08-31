///
/// Booked.hpp
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

// Forward declaration of `Balance` to properly resolve imports.
namespace margelo::nitro::financekit { struct Balance; }

#include "Balance.hpp"

namespace margelo::nitro::financekit {

  /**
   * A struct which can be represented as a JavaScript object (Booked).
   */
  struct Booked {
  public:
    Balance booked     SWIFT_PRIVATE;

  public:
    explicit Booked(Balance booked): booked(booked) {}
  };

} // namespace margelo::nitro::financekit

namespace margelo::nitro {

  using namespace margelo::nitro::financekit;

  // C++ Booked <> JS Booked (object)
  template <>
  struct JSIConverter<Booked> {
    static inline Booked fromJSI(jsi::Runtime& runtime, const jsi::Value& arg) {
      jsi::Object obj = arg.asObject(runtime);
      return Booked(
        JSIConverter<Balance>::fromJSI(runtime, obj.getProperty(runtime, "booked"))
      );
    }
    static inline jsi::Value toJSI(jsi::Runtime& runtime, const Booked& arg) {
      jsi::Object obj(runtime);
      obj.setProperty(runtime, "booked", JSIConverter<Balance>::toJSI(runtime, arg.booked));
      return obj;
    }
    static inline bool canConvert(jsi::Runtime& runtime, const jsi::Value& value) {
      if (!value.isObject()) {
        return false;
      }
      jsi::Object obj = value.getObject(runtime);
      if (!JSIConverter<Balance>::canConvert(runtime, obj.getProperty(runtime, "booked"))) return false;
      return true;
    }
  };

} // namespace margelo::nitro
