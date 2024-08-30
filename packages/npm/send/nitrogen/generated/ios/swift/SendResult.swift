///
/// SendResult.swift
/// Fri Aug 30 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

import NitroModules

/**
 * Represents an instance of `SendResult`, backed by a C++ struct.
 */
public typealias SendResult = margelo.nitro.send.SendResult

public extension SendResult {
  private typealias bridge = margelo.nitro.send.bridge.swift

  /**
   * Create a new instance of `SendResult`.
   */
  init(response: Response?, error: SendError?) {
    self.init({ () -> bridge.std__optional_Response_ in
      if let actualValue = response {
        return bridge.create_std__optional_Response_(actualValue)
      } else {
        return .init()
      }
    }(), { () -> bridge.std__optional_SendError_ in
      if let actualValue = error {
        return bridge.create_std__optional_SendError_(actualValue)
      } else {
        return .init()
      }
    }())
  }

  var response: Response? {
    @inline(__always)
    get {
      return { () -> Response? in
        if let actualValue = self.__response.value {
          return actualValue
        } else {
          return nil
        }
      }()
    }
    @inline(__always)
    set {
      self.__response = { () -> bridge.std__optional_Response_ in
        if let actualValue = newValue {
          return bridge.create_std__optional_Response_(actualValue)
        } else {
          return .init()
        }
      }()
    }
  }
  
  var error: SendError? {
    @inline(__always)
    get {
      return { () -> SendError? in
        if let actualValue = self.__error.value {
          return actualValue
        } else {
          return nil
        }
      }()
    }
    @inline(__always)
    set {
      self.__error = { () -> bridge.std__optional_SendError_ in
        if let actualValue = newValue {
          return bridge.create_std__optional_SendError_(actualValue)
        } else {
          return .init()
        }
      }()
    }
  }
}
