///
/// Request.swift
/// Fri Aug 30 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

import NitroModules

/**
 * Represents an instance of `Request`, backed by a C++ struct.
 */
public typealias Request = margelo.nitro.send.Request

public extension Request {
  private typealias bridge = margelo.nitro.send.bridge.swift

  /**
   * Create a new instance of `Request`.
   */
  init(baseURL: String, path: String, query: Parameters, header: Parameters, method: Method, body: String?, utf8ContentTypes: [String]) {
    self.init(std.string(baseURL), std.string(path), query, header, method, { () -> bridge.std__optional_std__string_ in
      if let actualValue = body {
        return bridge.create_std__optional_std__string_(std.string(actualValue))
      } else {
        return .init()
      }
    }(), { () -> bridge.std__vector_std__string_ in
      var vector = bridge.create_std__vector_std__string_(utf8ContentTypes.count)
      for item in utf8ContentTypes {
        vector.push_back(std.string(item))
      }
      return vector
    }())
  }

  var baseURL: String {
    @inline(__always)
    get {
      return String(self.__baseURL)
    }
    @inline(__always)
    set {
      self.__baseURL = std.string(newValue)
    }
  }
  
  var path: String {
    @inline(__always)
    get {
      return String(self.__path)
    }
    @inline(__always)
    set {
      self.__path = std.string(newValue)
    }
  }
  
  var query: Parameters {
    @inline(__always)
    get {
      return self.__query
    }
    @inline(__always)
    set {
      self.__query = newValue
    }
  }
  
  var header: Parameters {
    @inline(__always)
    get {
      return self.__header
    }
    @inline(__always)
    set {
      self.__header = newValue
    }
  }
  
  var method: Method {
    @inline(__always)
    get {
      return self.__method
    }
    @inline(__always)
    set {
      self.__method = newValue
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
  
  var utf8ContentTypes: [String] {
    @inline(__always)
    get {
      return self.__utf8ContentTypes.map({ val in String(val) })
    }
    @inline(__always)
    set {
      self.__utf8ContentTypes = { () -> bridge.std__vector_std__string_ in
        var vector = bridge.create_std__vector_std__string_(newValue.count)
        for item in newValue {
          vector.push_back(std.string(item))
        }
        return vector
      }()
    }
  }
}