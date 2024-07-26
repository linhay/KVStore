//
//  File.swift
//  
//
//  Created by linhey on 2024/7/26.
//

import Foundation

public struct AsyncKVStoreGroup: AsyncKVStore {
    
    public let stores: [AsyncKVStore]
    
    public init(stores: [AsyncKVStore]) {
        self.stores = stores
    }
    
    public init(stores: [AnyKVStore]) {
        self.stores = stores.map(\.rawValue)
    }
    
}

public extension AsyncKVStoreGroup {
    
    func asyncGet<T>(_ key: String) async throws -> T? where T : KVValue {
        for store in self.stores {
            if let value = try await store.asyncGet(key) as T? {
                return value
            }
        }
        return nil
    }
    
    func asyncSet<T>(_ key: String, _ value: T?) async throws where T : KVValue {
        for store in self.stores {
            try await store.asyncSet(key, value)
        }
    }
    
    func asyncAll() async throws -> [String : Any] {
        var items = [String : Any]()
        for store in self.stores {
            try await items.merge(store.asyncAll()) { $1 }
        }
        return items
    }
    
}
