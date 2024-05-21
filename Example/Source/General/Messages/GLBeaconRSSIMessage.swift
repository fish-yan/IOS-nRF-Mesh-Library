//
//  GLBeaconOnOffMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

public struct GLBeaconRSSIMessage: GLMessage {
    public static var responseType: NordicMesh.StaticMeshResponse.Type {
        return GLBeaconRSSIStatus.self
    }
    
    public static var code: UInt32 = 0x21
        
    public var parameters: Data?
    
    init(rssi: UInt8) {
        self.parameters = Data() + rssi
    }
}

public struct GLBeaconRSSIStatus: GLResponse {
    public static var code: UInt32 = 0x21
    
    public var parameters: Data?
    
    public let rssi: UInt8
    
    public init?(parameters: Data) {
        self.parameters = parameters
        rssi = parameters.asUInt8
    }
    
}
