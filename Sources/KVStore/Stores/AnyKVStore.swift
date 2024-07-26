//
//  KVStoreSet.swift
//  Quack
//
//  Created by linhey on 2023/12/8.
//

import Foundation

public struct AnyKVStore {
    
    public let rawValue: KVStore
    
    public init(_ store: KVStore) {
        self.rawValue = store
    }
    
    public static var keychain: AnyKVStore { AnyKVStore(KVKeychainStore.shared) }
    public static var ubiquitous: AnyKVStore { AnyKVStore(KVUbiquitousStore.shared) }
    public static var userDefault: AnyKVStore { AnyKVStore(KVUserDefaultStore.shared) }

}

