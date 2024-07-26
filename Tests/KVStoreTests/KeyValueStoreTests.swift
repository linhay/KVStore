import XCTest
import KVStore

class AsyncCustomStore: AsyncKVStore {
    
    func asyncGet<T>(_ key: String) async throws -> T? where T : KVValue {
        nil
    }
    
    func asyncSet<T>(_ key: String, _ value: T?) async throws where T : KVValue {
        
    }
    
    func asyncAll() async throws -> [String : Any] {
        [:]
    }
    
}

class CustomStore: KVStore {
    
    func get<T: KVValue>(_ key: String) throws -> T? {
        switch T.valueType {
        case .array:
            return [1, 2, 3] as? T
        default:
            return nil
        }
    }
    
    func set<T: KVValue>(_ key: String, _ value: T?) throws {
        
    }
    
    func all() throws -> [String : Any] {
        [:]
    }
    
}

extension AnyKVStore {
    static var custom: AnyKVStore { .init(CustomStore()) }
}

struct Settings {
    @KVField("user_token", default: "", store: .keychain)
    var userName: String
    @KVOptionalField("user_age", store: .keychain)
    var userAge: Int?
}

struct Credentials {
    @KVField("user_token", default: "", store: [.keychain, .ubiquitous, .userDefault, .custom])
    var userToken: String
}

final class KeyValueStoreTests: XCTestCase {
    
    func testExample() async throws {
        let store = CustomStore()
        let token: String? = try store.get("user_token")
        try store.set("user_token", "123")
    }
    
}
