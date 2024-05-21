//
//  GLBeaconOnOffMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

public struct GLBeaconUUIDSetMessage: GLMessage {
    public static var responseType: NordicMesh.StaticMeshResponse.Type {
        return GLBeaconUUIDSetStatus.self
    }
    
    public static var code: UInt32 = 0x23
        
    public var parameters: Data?
    
    init(uuidHex: String) {
        self.parameters = Data(hex: uuidHex)
    }
}

public struct GLBeaconUUIDSetStatus: GLResponse {
    public static var code: UInt32 = 0x23
    
    public var parameters: Data?
    
    public let uuidHex: String
    
    public init?(parameters: Data) {
        self.parameters = parameters
        uuidHex = parameters.toHexString()
    }
    
}
