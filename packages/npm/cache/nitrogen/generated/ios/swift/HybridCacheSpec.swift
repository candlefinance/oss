///
/// HybridCacheSpec.swift
/// Fri Aug 30 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/react-native-nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

import Foundation
import NitroModules

/**
 * A Swift protocol representing the Cache HybridObject.
 * Implement this protocol to create Swift-based instances of Cache.
 *
 * When implementing this protocol, make sure to initialize `hybridContext` - example:
 * ```
 * public class HybridCache : HybridCacheSpec {
 *   // Initialize HybridContext
 *   var hybridContext = margelo.nitro.HybridContext()
 *
 *   // Return size of the instance to inform JS GC about memory pressure
 *   var memorySize: Int {
 *     return getSizeOf(self)
 *   }
 *
 *   // ...
 * }
 * ```
 */
public protocol HybridCacheSpec: HybridObjectSpec {
  // Properties
  

  // Methods
  func write(key: String, object: String) throws -> Void
  func writeAsync(key: String, object: String) throws -> Promise<Void>
  func readAsync(key: String) throws -> Promise<String?>
  func read(key: String) throws -> String?
  func removeAsync(key: String) throws -> Promise<Void>
  func remove(key: String) throws -> Void
  func clearAsync() throws -> Promise<Void>
  func clear() throws -> Void
}

public extension HybridCacheSpec {
  /**
   * Create a new instance of HybridCacheSpecCxx for the given HybridCacheSpec.
   *
   * Instances of HybridCacheSpecCxx can be accessed from C++, and contain
   * additional required bridging code for C++ <> Swift interop.
   */
  func createCxxBridge() -> HybridCacheSpecCxx {
    return HybridCacheSpecCxx(self)
  }
}
