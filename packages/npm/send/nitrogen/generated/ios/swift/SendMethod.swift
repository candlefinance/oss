///
/// SendMethod.swift
/// Mon Sep 02 2024
/// This file was generated by nitrogen. DO NOT MODIFY THIS FILE.
/// https://github.com/mrousavy/nitro
/// Copyright © 2024 Marc Rousavy @ Margelo
///

/**
 * Represents the JS union `SendMethod`, backed by a C++ enum.
 */
public typealias SendMethod = margelo.nitro.send.SendMethod

public extension SendMethod {
  /**
   * Get a SendMethod for the given String value, or
   * return `nil` if the given value was invalid/unknown.
   */
  init?(fromString string: String) {
    switch string {
      case "GET":
        self = .get
      case "POST":
        self = .post
      case "PUT":
        self = .put
      case "DELETE":
        self = .delete
      case "PATCH":
        self = .patch
      case "HEAD":
        self = .head
      case "OPTIONS":
        self = .options
      case "CONNECT":
        self = .connect
      case "TRACE":
        self = .trace
      default:
        return nil
    }
  }

  /**
   * Get the String value this SendMethod represents.
   */
  var stringValue: String {
    switch self {
      case .get:
        return "GET"
      case .post:
        return "POST"
      case .put:
        return "PUT"
      case .delete:
        return "DELETE"
      case .patch:
        return "PATCH"
      case .head:
        return "HEAD"
      case .options:
        return "OPTIONS"
      case .connect:
        return "CONNECT"
      case .trace:
        return "TRACE"
    }
  }
}
