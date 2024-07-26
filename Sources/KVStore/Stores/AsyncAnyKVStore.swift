//
//  File.swift
//  
//
//  Created by linhey on 2024/7/26.
//

import Foundation

public struct AsyncAnyKVStore {
    
    public let rawValue: AsyncKVStore
    
    public init(_ store: AsyncKVStore) {
        self.rawValue = store
    }
    
    public static var keychain: AsyncAnyKVStore { AsyncAnyKVStore(KVKeychainStore.shared) }
    public static var ubiquitous: AsyncAnyKVStore { AsyncAnyKVStore(KVUbiquitousStore.shared) }
    public static var userDefault: AsyncAnyKVStore { AsyncAnyKVStore(KVUserDefaultStore.shared) }

}
