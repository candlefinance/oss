///
/// candlefinance_send-Swift-Cxx-Umbrella.hpp
/// Wed Aug 28 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/react-native-nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

#pragma once

// Forward declarations of C++ defined types
// Forward declaration of `Parameters` to properly resolve imports.
namespace margelo::nitro::send { struct Parameters; }
// Forward declaration of `Request` to properly resolve imports.
namespace margelo::nitro::send { struct Request; }
// Forward declaration of `Response` to properly resolve imports.
namespace margelo::nitro::send { struct Response; }

// Include C++ defined types
#include "Parameters.hpp"
#include "Request.hpp"
#include "Response.hpp"
#include <future>
#include <optional>
#include <string>
#include <unordered_map>
#include <vector>

// C++ helpers for Swift
#include "candlefinance_send-Swift-Cxx-Bridge.hpp"

// Common Swift bridges for C++ types
#include <NitroModules/ArrayBufferHolder.hpp>
#include <NitroModules/PromiseHolder.hpp>

// Forward declarations of Swift defined types


// Include Swift defined types
#if __has_include("candlefinance_send-Swift.h")
// This header is generated by Xcode/Swift on every app build.
// If it cannot be found, make sure the Swift module's name (= podspec name) is actually "candlefinance_send".
#include "candlefinance_send-Swift.h"
#else
#error candlefinance_send's autogenerated Swift header cannot be found! Make sure the Swift module's name (= podspec name) is actually "candlefinance_send", and try building the app first.
#endif
