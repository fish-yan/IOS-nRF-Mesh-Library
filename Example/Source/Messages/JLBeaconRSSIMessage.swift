//
//  JLBeaconOnOffMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct JLBeaconRSSIMessage: JLMessage {
    
    public static var code: UInt32 = 0x21
        
    public var parameters: Data?
    
    init(rssi: Int16) {
        self.parameters = Data() + rssi
    }
}

public struct JLBeaconRSSIStatus: JLResponse {
    public static var code: UInt32 = 0x21
    
    public var parameters: Data?
    
    public let rssi: Int16
    
    public init?(parameters: Data) {
        self.parameters = parameters
        rssi = Int16(parameters.asUInt16)
    }
    
}
