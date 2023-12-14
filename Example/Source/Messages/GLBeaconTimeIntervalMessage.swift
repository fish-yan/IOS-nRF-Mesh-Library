//
//  GLBeaconOnOffMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct GLBeaconTimeIntervalMessage: GLMessage {
    public static var responseType: nRFMeshProvision.StaticMeshResponse.Type {
        return GLBeaconTimeIntervalStatus.self
    }
    
    public static var code: UInt32 = 0x22
        
    public var parameters: Data?
    
    init(timeInterval: UInt8) {
        self.parameters = Data() + timeInterval
    }
}

public struct GLBeaconTimeIntervalStatus: GLResponse {
    public static var code: UInt32 = 0x22
    
    public var parameters: Data?
    
    public let timeInterval: UInt8
    
    public init?(parameters: Data) {
        self.parameters = parameters
        timeInterval = parameters.asUInt8
    }
    
}
