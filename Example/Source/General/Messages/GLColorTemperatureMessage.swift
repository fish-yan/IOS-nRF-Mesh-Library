//
//  ColorTemperatureMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

public struct GLColorTemperatureMessage: GLMessage {
    public static var responseType: NordicMesh.StaticMeshResponse.Type {
        return GLColorTemperatureStatus.self
    }
    
    public static var code: UInt32 = 0x5
        
    public var parameters: Data?
    
    init(colorTemperature: UInt8) {
        self.parameters = Data() + colorTemperature
    }
}

public struct GLColorTemperatureStatus: GLResponse {
    
    public static var code: UInt32 = 0x5
    
    public var parameters: Data?
    
    public let colorTemperature: UInt8
    
    public init?(parameters: Data) {
        self.parameters = parameters
        colorTemperature = UInt8(parameters.toHexString(), radix: 16) ?? 0
    }
    
}

//struct ColorTemperatureMessage: VendorMessage {
//    let opCode: UInt32
//    let parameters: Data?
//
//    var isSegmented: Bool = false
//    var security: MeshMessageSecurity = .low
//
//    init(colorTemperature: UInt16) {
//        self.opCode = (UInt32(0xC0 | 0x5) << 16) | UInt32(0x0841.bigEndian)
//        self.parameters = Data() + colorTemperature
//    }
//
//    init?(parameters: Data) {
//        // This init will never be used, as it's used for incoming messages.
//        return nil
//    }
//}
