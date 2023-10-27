//
//  JLGlobalOnOffMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct JLGlobalOnOffMessage: JLMessage {
    
    public static var code: UInt32 = 0x12
        
    public var parameters: Data?
    
    init(status: JLSimpleStatus) {
        self.parameters = Data() + Int16(status.rawValue)
    }
}

public struct JLGlobalOnOffStatus: JLResponse {
    public static var code: UInt32 = 0x12
    
    public var parameters: Data?
    
    public let status: JLSimpleStatus
    
    public init?(parameters: Data) {
        self.parameters = parameters
        let raw = Int(parameters.asUInt16)
        status = JLSimpleStatus(rawValue: raw) ?? .off
    }
    
}
