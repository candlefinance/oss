///
/// candlefinance_send-Swift-Cxx-Bridge.hpp
/// Wed Aug 28 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/react-native-nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

#pragma once

// Forward declarations of C++ defined types
// Forward declaration of `Response` to properly resolve imports.
namespace margelo::nitro::send { struct Response; }

// Include C++ defined types
#include "Response.hpp"
#include <NitroModules/PromiseHolder.hpp>
#include <future>
#include <optional>
#include <string>
#include <unordered_map>
#include <vector>

/**
 * Contains specialized versions of C++ templated types so they can be accessed from Swift,
 * as well as helper functions to interact with those C++ types from Swift.
 */
namespace margelo::nitro::send::bridge::swift {

  /**
   * Specialized version of `std::unordered_map<std::string, std::string>`.
   */
  using std__unordered_map_std__string__std__string_ = std::unordered_map<std::string, std::string>;
  inline std::unordered_map<std::string, std::string> create_std__unordered_map_std__string__std__string_(size_t size) {
    std::unordered_map<std::string, std::string> map;
    map.reserve(size);
    return map;
  }
  inline std::vector<std::string> get_std__unordered_map_std__string__std__string__keys(const std__unordered_map_std__string__std__string_& map) {
    std::vector<std::string> keys;
    keys.reserve(map.size());
    for (const auto& entry : map) {
      keys.push_back(entry.first);
    }
    return keys;
  }
  
  /**
   * Specialized version of `std::optional<std::string>`.
   */
  using std__optional_std__string_ = std::optional<std::string>;
  inline std::optional<std::string> create_std__optional_std__string_(const std::string& value) {
    return std::optional<std::string>(value);
  }
  
  /**
   * Specialized version of `PromiseHolder<Response>`.
   */
  using PromiseHolder_Response_ = PromiseHolder<Response>;
  inline PromiseHolder<Response> create_PromiseHolder_Response_() {
    return PromiseHolder<Response>();
  }
  
  /**
   * Specialized version of `std::vector<std::string>`.
   */
  using std__vector_std__string_ = std::vector<std::string>;
  inline std::vector<std::string> create_std__vector_std__string_(size_t size) {
    std::vector<std::string> vector;
    vector.reserve(size);
    return vector;
  }

} // namespace margelo::nitro::send::bridge::swift
