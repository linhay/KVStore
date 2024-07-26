//
//  KeyValueStore.swift
//  Quack
//
//  Created by linhey on 2023/12/8.
//

import Foundation

public protocol AsyncKVStore {
    
    func asyncGet<T: KVValue>(_ key: String) async throws -> T?
    func asyncSet<T: KVValue>(_ key: String, _ value: T?) async throws
    func asyncAll() async throws -> [String : Any]
    
}

public protocol KVStore: AsyncKVStore {
    
    func get<T: KVValue>(_ key: String) throws -> T?
    func set<T: KVValue>(_ key: String, _ value: T?) throws
    func all() throws -> [String : Any]
    
}

public extension KVStore {
    
    func asyncGet<T: KVValue>(_ key: String) async throws -> T? {
      try get(key)
    }
    
    func asyncSet<T: KVValue>(_ key: String, _ value: T?) async throws {
        try set(key, value)
    }
    
    func asyncAll() async throws -> [String : Any] {
        try all()
    }
    
}

