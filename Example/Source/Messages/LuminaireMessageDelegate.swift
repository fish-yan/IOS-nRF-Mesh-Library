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

public protocol LuminaireMessage: StaticVendorMessage {
    static var code: UInt32 { get }
}

extension LuminaireMessage {
    public static var opCode: UInt32 { (UInt32(0xC0 | code) << 16) | UInt32(companyId.bigEndian) }
        
    public init?(parameters: Data) {
        return nil
    }
}

public protocol LuminaireResponse: StaticMeshMessage {
    static var code: UInt32 { get }
}

extension LuminaireResponse {
    public static var opCode: UInt32 { (UInt32(0xC0 | code) << 16) | UInt32(companyId.bigEndian) }
}
public enum LuminaireSimpleStatus: Int {
    case off = 0
    case on = 1
    case read = 2
}

let luminaireResponseTypes: [LuminaireResponse.Type] = [
    LuminaireColorTemperatureStatus.self,
    LuminaireAngleStatus.self,
    LuminaireAiStatus.self,
    LuminaireSensorStatus.self
]
