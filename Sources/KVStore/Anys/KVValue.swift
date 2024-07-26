//
//  KVStoreValue.swift
//  Quack
//
//  Created by linhey on 2023/12/8.
//

import Foundation

public enum KVValueType {
    case bool
    case int
    case uInt
    case int64
    case float
    case double
    case string
    case date
    case data
    case array
    case dictionary
    case codable
}

public protocol KVValue: Codable {
    static var valueType: KVValueType { get }
}



// MARK: Extension Swift Types
extension Bool: KVValue {
    public static var valueType: KVValueType { return .bool }
}

extension Int: KVValue {
    public static var valueType: KVValueType { return .int }
}

extension Int64: KVValue {
    public static var valueType: KVValueType { return .int64 }
}

extension UInt: KVValue {
    public static var valueType: KVValueType { return .uInt }
}

extension Float: KVValue {
    public static var valueType: KVValueType { return .float }
}

extension Double: KVValue {
    public static var valueType: KVValueType { return .double }
}

extension String: KVValue {
    public static var valueType: KVValueType { return .string }
}

extension Date: KVValue {
    public static var valueType: KVValueType { return .date }
}

extension Data: KVValue {
    public static var valueType: KVValueType { return .data }
}

extension Array: KVValue where Element: Codable {
    public static var valueType: KVValueType { return .codable }
}

extension Dictionary: KVValue where Key == String, Value: Codable {
    public static var valueType: KVValueType { return .dictionary }
}

extension KVValue where Self: Codable {
    public static var valueType: KVValueType { return .codable }
}
