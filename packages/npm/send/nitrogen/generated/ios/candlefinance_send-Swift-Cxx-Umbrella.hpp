///
/// candlefinance_send-Swift-Cxx-Umbrella.hpp
/// Mon Sep 02 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

#pragma once

// Forward declarations of C++ defined types
// Forward declaration of `SendErrorCode` to properly resolve imports.
namespace margelo::nitro::send { enum class SendErrorCode; }
// Forward declaration of `SendError` to properly resolve imports.
namespace margelo::nitro::send { struct SendError; }
// Forward declaration of `SendMethod` to properly resolve imports.
namespace margelo::nitro::send { enum class SendMethod; }
// Forward declaration of `SendParameters` to properly resolve imports.
namespace margelo::nitro::send { struct SendParameters; }
// Forward declaration of `SendRequest` to properly resolve imports.
namespace margelo::nitro::send { struct SendRequest; }
// Forward declaration of `SendResponse` to properly resolve imports.
namespace margelo::nitro::send { struct SendResponse; }
// Forward declaration of `SendResult` to properly resolve imports.
namespace margelo::nitro::send { struct SendResult; }

// Include C++ defined types
#include "SendError.hpp"
#include "SendErrorCode.hpp"
#include "SendMethod.hpp"
#include "SendParameters.hpp"
#include "SendRequest.hpp"
#include "SendResponse.hpp"
#include "SendResult.hpp"
#include <future>
#include <optional>
#include <string>
#include <unordered_map>
#include <vector>

// C++ helpers for Swift
#include "candlefinance_send-Swift-Cxx-Bridge.hpp"

// Common C++ types used in Swift
#include <NitroModules/ArrayBufferHolder.hpp>
#include <NitroModules/AnyMapHolder.hpp>
#include <NitroModules/HybridContext.hpp>
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
