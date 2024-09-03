///
/// Available.swift
/// Sat Aug 31 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

import NitroModules

/**
 * Represents an instance of `Available`, backed by a C++ struct.
 */
public typealias Available = margelo.nitro.financekit.Available

public extension Available {
  private typealias bridge = margelo.nitro.financekit.bridge.swift

  /**
   * Create a new instance of `Available`.
   */
  init(available: Balance) {
    self.init(available)
  }

  var available: Balance {
    @inline(__always)
    get {
      return self.__available
    }
    @inline(__always)
    set {
      self.__available = newValue
    }
  }
}
