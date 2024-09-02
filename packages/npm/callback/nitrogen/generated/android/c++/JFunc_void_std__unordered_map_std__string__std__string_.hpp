///
/// JFunc_void_std__unordered_map_std__string__std__string_.hpp
/// Mon Sep 02 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

#pragma once

#include <fbjni/fbjni.h>
#include <functional>

#include <functional>
#include <unordered_map>
#include <string>

namespace margelo::nitro::callback {

  using namespace facebook;

  /**
   * C++ representation of the callback Func_void_std__unordered_map_std__string__std__string_.
   * This is a Kotlin `(data: Map<String, String>) -> Unit`, backed by a `std::function<...>`.
   */
  struct JFunc_void_std__unordered_map_std__string__std__string_ final: public jni::HybridClass<JFunc_void_std__unordered_map_std__string__std__string_> {
  public:
    static jni::local_ref<JFunc_void_std__unordered_map_std__string__std__string_::javaobject> fromCpp(const std::function<void(const std::unordered_map<std::string, std::string>& /* data */)>& func) {
      return JFunc_void_std__unordered_map_std__string__std__string_::newObjectCxxArgs(func);
    }

  public:
    void call(const jni::alias_ref<jni::JMap<jni::JString, jni::JString>>& data) {
      return _func([&]() {
        std::unordered_map<std::string, std::string> map;
        map.reserve(data->size());
        for (const auto& entry : *data) {
          map.emplace(entry.first->toStdString(), entry.second->toStdString());
        }
        return map;
      }());
    }

  public:
    static auto constexpr kJavaDescriptor = "Lcom/margelo/nitro/candlefinance_callback/Func_void_std__unordered_map_std__string__std__string_;";
    static void registerNatives() {
      registerHybrid({makeNativeMethod("call", JFunc_void_std__unordered_map_std__string__std__string_::call)});
    }

  private:
    explicit JFunc_void_std__unordered_map_std__string__std__string_(const std::function<void(const std::unordered_map<std::string, std::string>& /* data */)>& func): _func(func) { }

  private:
    friend HybridBase;
    std::function<void(const std::unordered_map<std::string, std::string>& /* data */)> _func;
  };

} // namespace margelo::nitro::callback
