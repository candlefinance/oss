///
/// SendResponse.swift
/// Mon Sep 02 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

import NitroModules

/**
 * Represents an instance of `SendResponse`, backed by a C++ struct.
 */
public typealias SendResponse = margelo.nitro.send.SendResponse

public extension SendResponse {
  private typealias bridge = margelo.nitro.send.bridge.swift

  /**
   * Create a new instance of `SendResponse`.
   */
  init(statusCode: Double, header: SendParameters, body: String?) {
    self.init(statusCode, header, { () -> bridge.std__optional_std__string_ in
      if let actualValue = body {
        return bridge.create_std__optional_std__string_(std.string(actualValue))
      } else {
        return .init()
      }
    }())
  }

  var statusCode: Double {
    @inline(__always)
    get {
      return self.__statusCode
    }
    @inline(__always)
    set {
      self.__statusCode = newValue
    }
  }
  
  var header: SendParameters {
    @inline(__always)
    get {
      return self.__header
    }
    @inline(__always)
    set {
      self.__header = newValue
    }
  }
  
  var body: String? {
    @inline(__always)
    get {
      return { () -> String? in
        if let actualValue = self.__body.value {
          return String(actualValue)
        } else {
          return nil
        }
      }()
    }
    @inline(__always)
    set {
      self.__body = { () -> bridge.std__optional_std__string_ in
        if let actualValue = newValue {
          return bridge.create_std__optional_std__string_(std.string(actualValue))
        } else {
          return .init()
        }
      }()
    }
  }
}
