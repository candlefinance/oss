///
/// HybridSendSpec.swift
/// Thu Aug 29 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/react-native-nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

import Foundation
import NitroModules

/**
 * A Swift protocol representing the Send HybridObject.
 * Implement this protocol to create Swift-based instances of Send.
 *
 * When implementing this protocol, make sure to initialize `hybridContext` - example:
 * ```
 * public class HybridSend : HybridSendSpec {
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
public protocol HybridSendSpec: HybridObjectSpec {
  // Properties
  

  // Methods
  func send(request: Request) throws -> Promise<SendResult>
}

public extension HybridSendSpec {
  /**
   * Create a new instance of HybridSendSpecCxx for the given HybridSendSpec.
   *
   * Instances of HybridSendSpecCxx can be accessed from C++, and contain
   * additional required bridging code for C++ <> Swift interop.
   */
  func createCxxBridge() -> HybridSendSpecCxx {
    return HybridSendSpecCxx(self)
  }
}
