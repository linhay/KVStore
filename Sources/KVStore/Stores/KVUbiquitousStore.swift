//
//  UbiquitousKeyValueStore.swift
//  Quack
//
//  Created by linhey on 2023/12/8.
//

import Foundation

struct KVUbiquitousStore: KVStore {

    static let shared = KVUbiquitousStore()
    let store = NSUbiquitousKeyValueStore.default
    
    func synchronize() -> Bool {
        store.synchronize()
    }

    func all() -> [String : Any] {
        store.dictionaryRepresentation
    }
    
    func get<T>(_ key: String) -> T? where T: KVValue {
        switch T.valueType {
        case .bool:
            return store.bool(forKey: key) as? T
        case .int:
            let temp = store.longLong(forKey: key)
            return Int(temp) as? T
        case .uInt:
            let temp = store.longLong(forKey: key)
            return UInt(temp) as? T
        case .int64:
            return store.longLong(forKey: key) as? T
        case .float:
            let temp = store.double(forKey: key)
            return Float(temp) as? T
        case .double:
            return store.double(forKey: key) as? T
        case .string:
            return store.string(forKey: key) as? T
        case .date:
            let temp = store.double(forKey: key)
            return Date(timeIntervalSince1970: temp) as? T
        case .data:
            return store.data(forKey: key) as? T
        case .codable:
            guard let data = store.data(forKey: key) else {
                return nil
            }
            guard let value = try? JSONDecoder().decode(T.self, from: data) else {
                debugPrint("[KVUbiquitousStore] decode error")
                return nil
            }
            return value
        case .array:
            return store.array(forKey: key) as? T
        case .dictionary:
            return store.dictionary(forKey: key) as? T
        }
    }
    
    func set<T>(_ key: String, _ value: T?) where T: KVValue {
        guard let value = value else {
            store.removeObject(forKey: key)
            return
        }
        switch value {
        case let value as String:        store.set(value, forKey: key)
        case let value as Data:          store.set(value, forKey: key)
        case let value as Int64:         store.set(value, forKey: key)
        case let value as UInt:          store.set(Int64(value), forKey: key)
        case let value as Int:           store.set(Int64(value), forKey: key)
        case let value as Float:         store.set(Double(value), forKey: key)
        case let value as Date:          store.set(Double(value.timeIntervalSince1970), forKey: key)
        case let value as Double:        store.set(value, forKey: key)
        case let value as Bool:          store.set(value, forKey: key)
        case let value as [Any]:         store.set(value, forKey: key)
        case let value as [String: Any]: store.set(value, forKey: key)
        case let value as Codable:
            if let value = try? JSONEncoder().encode(value) {
                store.set(value, forKey: key)
            } else {
                debugPrint("[KVUbiquitousStore] encode error")
            }
        default:
            store.set(value, forKey: key)
        }
    }
    
}
