//
//  LuminaireMessageDelegate.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/24.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

fileprivate let companyId: Int16 = 0x0841

public protocol JLMessage: StaticVendorMessage {
    static var code: UInt32 { get }
}

extension JLMessage {
    public static var opCode: UInt32 { (UInt32(0xC0 | code) << 16) | UInt32(companyId.bigEndian) }
        
    public init?(parameters: Data) {
        return nil
    }
}

public protocol JLResponse: StaticMeshMessage {
    static var code: UInt32 { get }
}

extension JLResponse {
    public static var opCode: UInt32 { (UInt32(0xC0 | code) << 16) | UInt32(companyId.bigEndian) }
}

public enum JLSimpleStatus: Int {
    case off = 0
    case on = 1
    case read = 2
}

extension Data {
    var asUInt16: UInt16 {
        return (UInt16(self[0]) << 8) | UInt16(self[1])
    }
    
    func prePad(_ count: Int) -> Data {
        Data(repeating: 0, count: (Swift.max(0, count - self.count))) + self
    }
}

extension Array where Element == UInt16 {
    public static func + (lhs: Data, rhs: Self) -> Data {
        rhs.reduce(lhs, +)
    }
    
    public static func += (lhs: inout Data, rhs: Self) {
        lhs = lhs + rhs
    }
}

let jlResponseTypes: [JLResponse.Type] = [
    JLColorTemperatureStatus.self,
    JLAngleStatus.self,
    JLAiStatus.self,
    JLSensorStatus.self
]
