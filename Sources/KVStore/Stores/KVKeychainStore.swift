//
//  File.swift
//
//
//  Created by linhey on 2024/5/28.
//

import Foundation

public class KVKeychainStore: KVStore {
    
    static let shared = KVKeychainStore()
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let accessGroup: String?
    let asReference: Bool
    /// 当 kSecAttrSynchronizable 设置为 true 时，该密钥链项将与启用了 iCloud Keychain 的所有设备同步。
    let synchronizable: Bool
    let access: AccessOptions?
    
    public init(accessGroup: String? = nil,
                access: AccessOptions? = nil,
                synchronizable: Bool = false,
                asreference: Bool = false) {
        self.accessGroup = accessGroup
        self.synchronizable = synchronizable
        self.access = access
        self.asReference = asreference
    }
    
    public func keys() -> [String] {
        var query = self.query(of: nil)
        query[Keys.returnData] = true
        query[Keys.returnAttributes] = true
        query[Keys.returnReference] = true
        query[Keys.matchLimit] = Keys.secMatchLimitAll
        
        var result: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &result) == noErr {
            return (result as? [[String: Any]])?.compactMap {
                $0[Keys.attrAccount] as? String } ?? []
        }
        
        return []
    }
    
    public func all() -> [String : Any] {
        self.keys().reduce(into: [String: Any]()) { (result, key) in
            if let value: Data = try? get(key) {
                result[key] = value
            }
        }
    }
    
    public func get<T>(_ key: String) throws -> T? where T: KVValue {
        var query = self.query(of: key)
        query[Keys.matchLimit] = kSecMatchLimitOne
        var dataTypeRef: AnyObject? = nil
        // 执行查询
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr, let data = dataTypeRef as? Data {
            return try decoder.decode(T.self, from: data)
        } else {
            return nil
        }
    }
    
    public func set<T>(_ key: String, _ value: T?) throws where T: KVValue {
        guard let value = value else {
            let query = self.query(of: key)
            _ = SecItemDelete(query as CFDictionary) == noErr
            return
        }
        var query = self.query(of: key)
        query[Keys.valueData] = try encoder.encode(value)
        query[Keys.accessible] = access?.value ?? AccessOptions.defaultOption.value
        _ = SecItemAdd(query as CFDictionary, nil) == noErr
    }
    
}

extension KVKeychainStore {
    
    func synchronize() -> Bool {
        true
    }
    
    func query(of key: String?) -> [String : Any] {
        var query: [String: Any] = [Keys.klass: kSecClassGenericPassword]
        
        if let key = key {
            query[Keys.attrAccount] = key
        }
        
        if asReference {
            query[Keys.returnReference] = kCFBooleanTrue
        } else {
            query[Keys.returnData] = kCFBooleanTrue
        }
        
        if let accessGroup {
            query[Keys.accessGroup] = accessGroup
        }
        
        if synchronizable {
            query[Keys.attrSynchronizable] = kSecAttrSynchronizableAny
        }
        return query
    }
    
}

extension KVKeychainStore {
    /**
     
     These options are used to determine when a keychain item should be readable. The default value is AccessibleWhenUnlocked.
     
     */
    public enum AccessOptions {
        
        /**
         
         The data in the keychain item can be accessed only while the device is unlocked by the user.
         
         This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute migrate to a new device when using encrypted backups.
         
         This is the default value for keychain items added without explicitly setting an accessibility constant.
         
         */
        case accessibleWhenUnlocked
        
        /**
         
         The data in the keychain item can be accessed only while the device is unlocked by the user.
         
         This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
         
         */
        case accessibleWhenUnlockedThisDeviceOnly
        
        /**
         
         The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
         
         After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute migrate to a new device when using encrypted backups.
         
         */
        case accessibleAfterFirstUnlock
        
        /**
         
         The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
         
         After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
         
         */
        case accessibleAfterFirstUnlockThisDeviceOnly
        
        /**
         
         The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
         
         This is recommended for items that only need to be accessible while the application is in the foreground. Items with this attribute never migrate to a new device. After a backup is restored to a new device, these items are missing. No items can be stored in this class on devices without a passcode. Disabling the device passcode causes all items in this class to be deleted.
         
         */
        case accessibleWhenPasscodeSetThisDeviceOnly
        
        static var defaultOption: AccessOptions { .accessibleWhenUnlocked }
        
        var value: String {
            switch self {
            case .accessibleWhenUnlocked:
                return toString(kSecAttrAccessibleWhenUnlocked)
                
            case .accessibleWhenUnlockedThisDeviceOnly:
                return toString(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
                
            case .accessibleAfterFirstUnlock:
                return toString(kSecAttrAccessibleAfterFirstUnlock)
                
            case .accessibleAfterFirstUnlockThisDeviceOnly:
                return toString(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
                
            case .accessibleWhenPasscodeSetThisDeviceOnly:
                return toString(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
            }
        }
        
        func toString(_ value: CFString) -> String {
            return Keys.toString(value)
        }
    }
    
}

extension KVKeychainStore {
    
    public struct Keys {
        /// Specifies a Keychain access group. Used for sharing Keychain items between apps.
        public static var accessGroup: String { return toString(kSecAttrAccessGroup) }
        
        /**
         
         A value that indicates when your app needs access to the data in a keychain item. The default value is AccessibleWhenUnlocked. For a list of possible values, see KeychainSwiftAccessOptions.
         
         */
        public static var accessible: String { return toString(kSecAttrAccessible) }
        
        /// Used for specifying a String key when setting/getting a Keychain value.
        public static var attrAccount: String { return toString(kSecAttrAccount) }
        
        /// Used for specifying synchronization of keychain items between devices.
        public static var attrSynchronizable: String { return toString(kSecAttrSynchronizable) }
        
        /// An item class key used to construct a Keychain search dictionary.
        public static var klass: String { return toString(kSecClass) }
        
        /// Specifies the number of values returned from the keychain. The library only supports single values.
        public static var matchLimit: String { return toString(kSecMatchLimit) }
        
        /// A return data type used to get the data from the Keychain.
        public static var returnData: String { return toString(kSecReturnData) }
        
        /// Used for specifying a value when setting a Keychain value.
        public static var valueData: String { return toString(kSecValueData) }
        
        /// Used for returning a reference to the data from the keychain
        public static var returnReference: String { return toString(kSecReturnPersistentRef) }
        
        /// A key whose value is a Boolean indicating whether or not to return item attributes
        public static var returnAttributes : String { return toString(kSecReturnAttributes) }
        
        /// A value that corresponds to matching an unlimited number of items
        public static var secMatchLimitAll : String { return toString(kSecMatchLimitAll) }
        
        static func toString(_ value: CFString) -> String {
            return value as String
        }
    }
    
}
