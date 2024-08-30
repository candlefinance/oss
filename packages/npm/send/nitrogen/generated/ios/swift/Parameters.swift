///
/// Parameters.swift
/// Thu Aug 29 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/react-native-nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

import NitroModules

/**
 * Represents an instance of `Parameters`, backed by a C++ struct.
 */
public typealias Parameters = margelo.nitro.send.Parameters

public extension Parameters {
  private typealias bridge = margelo.nitro.send.bridge.swift

  /**
   * Create a new instance of `Parameters`.
   */
  init(parameters: Dictionary<String, String>) {
    self.init({ () -> bridge.std__unordered_map_std__string__std__string_ in
      var map = bridge.create_std__unordered_map_std__string__std__string_(parameters.count)
      for (k, v) in parameters {
        map[std.string(k)] = std.string(v)
      }
      return map
    }())
  }

  var parameters: Dictionary<String, String> {
    @inline(__always)
    get {
      return { () -> Dictionary<String, String> in
        var dictionary = Dictionary<String, String>(minimumCapacity: self.__parameters.size())
        let keys = bridge.get_std__unordered_map_std__string__std__string__keys(self.__parameters)
        for key in keys {
          let value = self.__parameters[key]
          dictionary[String(key)] = String(value!)
        }
        return dictionary
      }()
    }
    @inline(__always)
    set {
      self.__parameters = { () -> bridge.std__unordered_map_std__string__std__string_ in
        var map = bridge.create_std__unordered_map_std__string__std__string_(newValue.count)
        for (k, v) in newValue {
          map[std.string(k)] = std.string(v)
        }
        return map
      }()
    }
  }
}