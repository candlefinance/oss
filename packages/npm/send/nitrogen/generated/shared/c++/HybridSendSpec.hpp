///
/// HybridSendSpec.hpp
/// Fri Aug 30 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

#pragma once

#if __has_include(<NitroModules/HybridObject.hpp>)
#include <NitroModules/HybridObject.hpp>
#else
#error NitroModules cannot be found! Are you sure you installed NitroModules properly?
#endif

// Forward declaration of `SendResult` to properly resolve imports.
namespace margelo::nitro::send { struct SendResult; }
// Forward declaration of `Request` to properly resolve imports.
namespace margelo::nitro::send { struct Request; }

#include <future>
#include "SendResult.hpp"
#include "Request.hpp"

namespace margelo::nitro::send {

  using namespace margelo::nitro;

  /**
   * An abstract base class for `Send`
   * Inherit this class to create instances of `HybridSendSpec` in C++.
   * @example
   * ```cpp
   * class HybridSend: public HybridSendSpec {
   *   // ...
   * };
   * ```
   */
  class HybridSendSpec: public virtual HybridObject {
    public:
      // Constructor
      explicit HybridSendSpec(): HybridObject(TAG) { }

      // Destructor
      virtual ~HybridSendSpec() { }

    public:
      // Properties
      

    public:
      // Methods
      virtual std::future<SendResult> send(const Request& request) = 0;

    protected:
      // Hybrid Setup
      void loadHybridMethods() override;

    protected:
      // Tag for logging
      static constexpr auto TAG = "Send";
  };

} // namespace margelo::nitro::send
