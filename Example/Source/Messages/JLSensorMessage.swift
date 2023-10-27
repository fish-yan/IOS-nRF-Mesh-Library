//
//  SensorMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/25.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct JLSensorMessage: JLMessage {
    
    public static var code: UInt32 = 0xC
        
    public var parameters: Data?
    
    init(status: JLSimpleStatus) {
        self.parameters = Data() + Int16(status.rawValue)
    }
}

public struct JLSensorStatus: JLResponse {
    public static var code: UInt32 = 0xC
    
    public var parameters: Data?
    
    public let status: JLSimpleStatus
    
    public init?(parameters: Data) {
        self.parameters = parameters
        let raw = Int(parameters.toHexString(), radix: 16) ?? 0
        status = JLSimpleStatus(rawValue: raw) ?? .off
    }
    
}
