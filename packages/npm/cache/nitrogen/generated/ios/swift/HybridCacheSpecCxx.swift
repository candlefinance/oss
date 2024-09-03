///
/// HybridCacheSpecCxx.swift
/// Fri Aug 30 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

import Foundation
import NitroModules

/**
 * A class implementation that bridges HybridCacheSpec over to C++.
 * In C++, we cannot use Swift protocols - so we need to wrap it in a class to make it strongly defined.
 *
 * Also, some Swift types need to be bridged with special handling:
 * - Enums need to be wrapped in Structs, otherwise they cannot be accessed bi-directionally (Swift bug: https://github.com/swiftlang/swift/issues/75330)
 * - Other HybridObjects need to be wrapped/unwrapped from the Swift TCxx wrapper
 * - Throwing methods need to be wrapped with a Result<T, Error> type, as exceptions cannot be propagated to C++
 */
public final class HybridCacheSpecCxx {
  /**
   * The Swift <> C++ bridge's namespace (`margelo::nitro::cache::bridge::swift`)
   * from `candlefinance_cache-Swift-Cxx-Bridge.hpp`.
   * This contains specialized C++ templates, and C++ helper functions that can be accessed from Swift.
   */
  public typealias bridge = margelo.nitro.cache.bridge.swift

  /**
   * Holds an instance of the `HybridCacheSpec` Swift protocol.
   */
  private(set) var implementation: HybridCacheSpec

  /**
   * Create a new `HybridCacheSpecCxx` that wraps the given `HybridCacheSpec`.
   * All properties and methods bridge to C++ types.
   */
  public init(_ implementation: HybridCacheSpec) {
    self.implementation = implementation
  }

  /**
   * Contains a (weak) reference to the C++ HybridObject to cache it.
   */
  public var hybridContext: margelo.nitro.HybridContext {
    get {
      return self.implementation.hybridContext
    }
    set {
      self.implementation.hybridContext = newValue
    }
  }

  /**
   * Get the memory size of the Swift class (plus size of any other allocations)
   * so the JS VM can properly track it and garbage-collect the JS object if needed.
   */
  public var memorySize: Int {
    return self.implementation.memorySize
  }

  // Properties
  

  // Methods
  @inline(__always)
  public func write(key: std.string, object: std.string) -> Void {
    do {
      try self.implementation.write(key: String(key), object: String(object))
      return 
    } catch {
      let message = "\(error.localizedDescription)"
      fatalError("Swift errors can currently not be propagated to C++! See https://github.com/swiftlang/swift/issues/75290 (Error: \(message))")
    }
  }
  
  @inline(__always)
  public func writeAsync(key: std.string, object: std.string) -> bridge.PromiseHolder_void_ {
    do {
      let result = try self.implementation.writeAsync(key: String(key), object: String(object))
      return { () -> bridge.PromiseHolder_void_ in
        let promiseHolder = bridge.create_PromiseHolder_void_()
        result
          .then({ promiseHolder.resolve() })
          .catch({ promiseHolder.reject(std.string(String(describing: $0))) })
        return promiseHolder
      }()
    } catch {
      let message = "\(error.localizedDescription)"
      fatalError("Swift errors can currently not be propagated to C++! See https://github.com/swiftlang/swift/issues/75290 (Error: \(message))")
    }
  }
  
  @inline(__always)
  public func readAsync(key: std.string) -> bridge.PromiseHolder_std__optional_std__string__ {
    do {
      let result = try self.implementation.readAsync(key: String(key))
      return { () -> bridge.PromiseHolder_std__optional_std__string__ in
        let promiseHolder = bridge.create_PromiseHolder_std__optional_std__string__()
        result
          .then({ r in promiseHolder.resolve({ () -> bridge.std__optional_std__string_ in
        if let actualValue = r {
          return bridge.create_std__optional_std__string_(std.string(actualValue))
        } else {
          return .init()
        }
      }()) })
          .catch({ promiseHolder.reject(std.string(String(describing: $0))) })
        return promiseHolder
      }()
    } catch {
      let message = "\(error.localizedDescription)"
      fatalError("Swift errors can currently not be propagated to C++! See https://github.com/swiftlang/swift/issues/75290 (Error: \(message))")
    }
  }
  
  @inline(__always)
  public func read(key: std.string) -> bridge.std__optional_std__string_ {
    do {
      let result = try self.implementation.read(key: String(key))
      return { () -> bridge.std__optional_std__string_ in
        if let actualValue = result {
          return bridge.create_std__optional_std__string_(std.string(actualValue))
        } else {
          return .init()
        }
      }()
    } catch {
      let message = "\(error.localizedDescription)"
      fatalError("Swift errors can currently not be propagated to C++! See https://github.com/swiftlang/swift/issues/75290 (Error: \(message))")
    }
  }
  
  @inline(__always)
  public func removeAsync(key: std.string) -> bridge.PromiseHolder_void_ {
    do {
      let result = try self.implementation.removeAsync(key: String(key))
      return { () -> bridge.PromiseHolder_void_ in
        let promiseHolder = bridge.create_PromiseHolder_void_()
        result
          .then({ promiseHolder.resolve() })
          .catch({ promiseHolder.reject(std.string(String(describing: $0))) })
        return promiseHolder
      }()
    } catch {
      let message = "\(error.localizedDescription)"
      fatalError("Swift errors can currently not be propagated to C++! See https://github.com/swiftlang/swift/issues/75290 (Error: \(message))")
    }
  }
  
  @inline(__always)
  public func remove(key: std.string) -> Void {
    do {
      try self.implementation.remove(key: String(key))
      return 
    } catch {
      let message = "\(error.localizedDescription)"
      fatalError("Swift errors can currently not be propagated to C++! See https://github.com/swiftlang/swift/issues/75290 (Error: \(message))")
    }
  }
  
  @inline(__always)
  public func clearAsync() -> bridge.PromiseHolder_void_ {
    do {
      let result = try self.implementation.clearAsync()
      return { () -> bridge.PromiseHolder_void_ in
        let promiseHolder = bridge.create_PromiseHolder_void_()
        result
          .then({ promiseHolder.resolve() })
          .catch({ promiseHolder.reject(std.string(String(describing: $0))) })
        return promiseHolder
      }()
    } catch {
      let message = "\(error.localizedDescription)"
      fatalError("Swift errors can currently not be propagated to C++! See https://github.com/swiftlang/swift/issues/75290 (Error: \(message))")
    }
  }
  
  @inline(__always)
  public func clear() -> Void {
    do {
      try self.implementation.clear()
      return 
    } catch {
      let message = "\(error.localizedDescription)"
      fatalError("Swift errors can currently not be propagated to C++! See https://github.com/swiftlang/swift/issues/75290 (Error: \(message))")
    }
  }
}
