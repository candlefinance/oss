///
/// HybridFinanceKitSpec.swift
/// Sat Aug 31 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

import Foundation
import NitroModules

/**
 * A Swift protocol representing the FinanceKit HybridObject.
 * Implement this protocol to create Swift-based instances of FinanceKit.
 *
 * When implementing this protocol, make sure to initialize `hybridContext` - example:
 * ```
 * public class HybridFinanceKit : HybridFinanceKitSpec {
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
public protocol HybridFinanceKitSpec: HybridObjectSpec {
  // Properties
  

  // Methods
  func requestAuthorization() throws -> Promise<AuthorizationStatus>
  func authorizationStatus() throws -> Promise<AuthorizationStatus>
  func transactions(query: Query) throws -> Promise<[FinanceKitTransaction]>
  func transactionHistory(params: AccountDetailsHistoryParams) throws -> Promise<[FinanceKitTransaction]>
  func accounts(query: Query) throws -> Promise<[Account]>
  func accountHistory(params: AccountHistoryParams) throws -> Promise<[Account]>
  func accountBalances(query: Query) throws -> Promise<[FinanceKitAccountBalance]>
  func accountBalanceHistory(params: AccountDetailsHistoryParams) throws -> Promise<[FinanceKitAccountBalance]>
}

public extension HybridFinanceKitSpec {
  /**
   * Create a new instance of HybridFinanceKitSpecCxx for the given HybridFinanceKitSpec.
   *
   * Instances of HybridFinanceKitSpecCxx can be accessed from C++, and contain
   * additional required bridging code for C++ <> Swift interop.
   */
  func createCxxBridge() -> HybridFinanceKitSpecCxx {
    return HybridFinanceKitSpecCxx(self)
  }
}
