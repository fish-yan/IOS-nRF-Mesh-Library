//
//  GLBK06ZoneMessage.swift
//  nRF Mesh
//
//  Created by yan on 16/1/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

class GLBK06ZoneMessage: GLMessage {
    public static var responseType: NordicMesh.StaticMeshResponse.Type {
        return GLBK06ZoneStatus.self
    }
    
    public static var code: UInt32 = 0x14
        
    public var parameters: Data?
    
    init(zone: UInt8) {
        let address = String(format: "0x00D%02d0", zone)
        self.parameters = Data(hex: address)
    }
}

public struct GLBK06ZoneStatus: GLResponse {
    public static var code: UInt32 = 0x14
    
    public var parameters: Data?
    
    public let zone: UInt8
    
    public init?(parameters: Data) {
        self.parameters = parameters
        zone = parameters.asUInt8
    }
}
