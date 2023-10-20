//
//  LocalStorage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/18.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit


@propertyWrapper
struct Localed<Value> {
    private let key: LocalStorage.Key
    private var rawKey: String { "LocalStorageKey\(key.rawValue)" }
    private let initialValue: Value
    var wrappedValue: Value {
        get {
            UserDefaults.standard.value(forKey: rawKey) as? Value ?? initialValue
        }
        set {
            if let newValue = newValue as? AnyOptional, newValue.isNil {
                UserDefaults.standard.removeObject(forKey: rawKey)
            } else {
                UserDefaults.standard.set(newValue, forKey: rawKey)
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    init(wrappedValue value: Value, _ key: LocalStorage.Key) {
        self.key = key
        self.initialValue = value
    }
}

extension Localed where Value: ExpressibleByNilLiteral {
    init(_ key: LocalStorage.Key) {
        self.init(wrappedValue: nil, key)
    }
}

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

struct LocalStorage {
    @Localed(.userRole) static var userRole: String = "normal"
    @Localed(.onTransitionSteps) static var onTransitionSteps: UInt8 = 0
    @Localed(.offTransitionSteps) static var offTransitionSteps: UInt8 = 0
    @Localed(.onDelay) static var onDelay: UInt8 = 0
    @Localed(.offDelay) static var offDelay: UInt8 = 0
    @Localed(.level1) static var level1: Double = 75
    @Localed(.level2) static var level2: Double = 50
    @Localed(.level3) static var level3: Double = 25
    
    enum Key: String {
        case userRole
        case onTransitionSteps
        case offTransitionSteps
        case onDelay
        case offDelay
        case level1
        case level2
        case level3
    }
}
