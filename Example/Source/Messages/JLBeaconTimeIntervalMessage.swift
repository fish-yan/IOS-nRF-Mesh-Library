//
//  JLBeaconOnOffMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct JLBeaconTimeIntervalMessage: JLMessage {
    
    public static var code: UInt32 = 0x22
        
    public var parameters: Data?
    
    init(timeInterval: Int16) {
        self.parameters = Data() + timeInterval
    }
}

public struct JLBeaconTimeIntervalStatus: JLResponse {
    public static var code: UInt32 = 0x22
    
    public var parameters: Data?
    
    public let timeInterval: Int16
    
    public init?(parameters: Data) {
        self.parameters = parameters
        timeInterval = Int16(parameters.asUInt16)
    }
    
}
