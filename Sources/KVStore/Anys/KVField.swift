//
//  KVStoreField.swift
//  Quack
//
//  Created by linhey on 2023/12/8.
//

import Foundation

@propertyWrapper
public struct KVField<T: KVValue>: KVFieldProtocol {
    
    public let key: String
    public let defaultValue: T
    public let store: KVStore
    
    public init(_ key: String, default value: T, store: AnyKVStore) {
        self.init(key, default: value, store: store.rawValue)
    }
    
    public init(_ key: String, default value: T, store: [AnyKVStore]) {
        self.init(key, default: value, store: KVStoreGroup(stores: store))
    }
    
    public init(_ key: String, default value: T, store: KVStore) {
        self.key = key
        self.store = store
        self.defaultValue = value
    }
    
    public var wrappedValue: T {
        get { return (try? store.get(key) ?? defaultValue) ?? defaultValue }
        set { try? store.set(key, newValue) }
    }
    
    public var projectedValue: KVField<T> { return self }
}
