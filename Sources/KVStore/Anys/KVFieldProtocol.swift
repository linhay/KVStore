//
//  KVStoreFieldProtocol.swift
//  Quack
//
//  Created by linhey on 2023/12/8.
//

import Foundation

public protocol KVFieldProtocol {
    var key: String { get }
    var store: KVStore { get }
}
