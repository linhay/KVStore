//
//  KVStoreOptionalField.swift
//  Quack
//
//  Created by linhey on 2023/12/8.
//

import Foundation

@propertyWrapper
public struct KVOptionalField<T: KVValue>: KVFieldProtocol {
    
    public let key: String
    public let store: KVStore
    
    public init(_ key: String, store: KVStore) {
        self.key = key
        self.store = store
    }

    public init(_ key: String, store: AnyKVStore) {
        self.init(key, store: store.rawValue)
    }
    
    public init(_ key: String, store: [AnyKVStore]) {
        self.key = key
        self.store = KVStoreGroup(stores: store)
    }
    
    public var wrappedValue: T? {
        get { return try? store.get(key) }
        set { try? store.set(key, newValue) }
    }
    
    public var projectedValue: KVOptionalField<T> { return self }
}
