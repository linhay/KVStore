# KVStore - Versatile Key-Value Store Library for Swift

KVStore is a robust and flexible key-value store library designed for Swift, offering an elegant solution for managing user defaults, keychain storage, and various other key-value storage mechanisms with ease and type safety.

## Features

- **Multiple Storage Options**: Support for UserDefaults, Keychain, and custom stores.
- **Property Wrappers**: Simplified syntax for optional and non-optional values using property wrappers.
- **Async Support**: Perform key-value operations asynchronously.
- **Codable Support**: Effortlessly store and retrieve `Codable` types.
- **Type Safety**: Comprehensive type support including `Bool`, `Int`, `UInt`, `Int64`, `Float`, `Double`, `String`, `Date`, `Data`, `Array`, `Dictionary`, and custom `Codable` types.
- **Composable Stores**: Combine multiple stores into a unified interface.

## Installation

### Swift Package Manager

To integrate KVStore into your Xcode project using Swift Package Manager, add the following dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/linhay/KVStore.git", from: "0.0.1")
]
```

Then, include "KVStore" as a dependency for your target.

## Getting Started

### Basic Usage

#### Using User Defaults

Define a settings structure that uses `UserDefaults` to store values:

```swift
import KVStore

struct Settings {
    @KVField("user_name", default: "Guest", store: .userDefault)
    var userName: String
    
    @KVOptionalField("user_age", store: .userDefault)
    var userAge: Int?
}
```

#### Storing in Keychain

Define a structure to securely store credentials in Keychain:

```swift
import KVStore

struct Credentials {
    @KVField("user_token", default: "", store: .keychain)
    var userToken: String
}
```

### Custom Store Implementation

You can create a custom key-value store by conforming to the `KVStore` protocol. This flexibility allows you to adapt KVStore to various storage backends.

```swift
import KVStore

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
        // Custom implementation for setting values
    }
    
    func all() throws -> [String : Any] {
        return [:]
    }
}

extension AnyKVStore {
    static var custom: AnyKVStore { .init(CustomStore()) }
}
```

### Composable Stores

Combine multiple key-value stores into a single interface using `KVStoreGroup`:

```swift
import KVStore

struct Credentials {
    @KVField("user_token", default: "", store: [.keychain, .ubiquitous, .userDefault, .custom])
    var userToken: String
}
```

### Asynchronous Operations

Performing asynchronous key-value operations is straightforward with KVStore:

```swift
let store = CustomStore()
let token: String? = await try store.getAsync("user_token")
await try store.setAsync("user_token", "123")
```

## Testing

Here is an example of how you can test your custom key-value store using XCTest:

```swift
import XCTest
import KVStore

final class KeyValueStoreTests: XCTestCase {
    func testExample() async throws {
        let store = CustomStore()
        let token: String? = try store.get("user_token")
        XCTAssertEqual(token, nil)
        
        try store.set("user_token", "123")
        let newToken: String? = try store.get("user_token")
        XCTAssertEqual(newToken, "123")
    }
}
```

## Advanced Features

### Custom Data Types

Extend support for custom data types by conforming to the `KVValue` protocol:

```swift
import KVStore

struct CustomType: Codable, KVValue {
    static var valueType: KVValueType { return .codable }
    var id: Int
    var name: String
}
```

### Keychain Access Options

Customize keychain access with `AccessOptions`:

```swift
import KVStore

let secureStore = KVKeychainStore(access: .accessibleWhenUnlockedThisDeviceOnly)
```

## Contributing

Contributions are welcome! If you encounter issues, please open an issue on GitHub. For new features, please submit a pull request.

## License

KVStore is licensed under the MIT License. See [LICENSE](LICENSE) for more information.

## Acknowledgements

Thank you to all contributors and users of KVStore. Your support and feedback are invaluable.

---

This updated README includes more comprehensive examples, better organization, and additional testing information to provide a higher quality and detailed documentation for your project.