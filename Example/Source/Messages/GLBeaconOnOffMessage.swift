//
//  GLBeaconOnOffMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct GLBeaconOnOffMessage: GLMessage {
    
    public static var code: UInt32 = 0x20
        
    public var parameters: Data?
    
    init(status: GLSimpleStatus) {
        self.parameters = Data() + UInt8(status.rawValue)
    }
}

public struct GLBeaconOnOffStatus: GLResponse {
    public static var code: UInt32 = 0x20
    
    public var parameters: Data?
    
    public let status: GLSimpleStatus
    
    public init?(parameters: Data) {
        self.parameters = parameters
        let raw = Int(parameters.asUInt8)
        status = GLSimpleStatus(rawValue: raw) ?? .off
    }
    
}
