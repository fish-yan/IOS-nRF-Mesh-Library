//
//  JLBeaconOnOffMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct JLBeaconUUIDSetMessage: JLMessage {
    
    public static var code: UInt32 = 0x23
        
    public var parameters: Data?
    
    init(uuidHex: String) {
        self.parameters = Data(hex: uuidHex)
    }
}

public struct JLBeaconUUIDSetStatus: JLResponse {
    public static var code: UInt32 = 0x23
    
    public var parameters: Data?
    
    public let uuidHex: String
    
    public init?(parameters: Data) {
        self.parameters = parameters
        uuidHex = parameters.toHexString()
    }
    
}
