//
//  SensorMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/25.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct GLSensorMessage: GLMessage {
    public static var responseType: nRFMeshProvision.StaticMeshResponse.Type {
        return GLSensorStatus.self
    }
    
    public static var code: UInt32 = 0xC
        
    public var parameters: Data?
    
    public let status: GLSimpleStatus
    
    init(status: GLSimpleStatus) {
        self.parameters = Data() + UInt8(status.rawValue)
        self.status = status
    }
}

public struct GLSensorStatus: GLResponse {
    public static var code: UInt32 = 0xC
    
    public var parameters: Data?
    
    public let status: GLSimpleStatus
    
    public init?(parameters: Data) {
        self.parameters = parameters
        let raw = Int(parameters.toHexString(), radix: 16) ?? 0
        status = GLSimpleStatus(rawValue: raw) ?? .off
    }
    
}
