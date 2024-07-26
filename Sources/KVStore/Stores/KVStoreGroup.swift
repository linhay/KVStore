//
//  File.swift
//  
//
//  Created by linhey on 2024/5/28.
//

import Foundation

public struct KVStoreGroup: KVStore {
    
    public let stores: [KVStore]
    
    public init(stores: [KVStore]) {
        self.stores = stores
    }
    
    public init(stores: [AnyKVStore]) {
        self.stores = stores.map(\.rawValue)
    }
    
}

public extension KVStoreGroup {
    
    func get<T>(_ key: String) throws -> T? where T : KVValue {
        for store in self.stores {
            if let value = try store.get(key) as T? {
                return value
            }
        }
        return nil
    }
    
    func set<T>(_ key: String, _ value: T?) throws where T : KVValue {
        for store in self.stores {
            try store.set(key, value)
        }
    }
    
    func all() throws -> [String : Any] {
        var items = [String : Any]()
        for store in self.stores {
            try items.merge(store.all()) { $1 }
        }
        return items
    }
    
}
