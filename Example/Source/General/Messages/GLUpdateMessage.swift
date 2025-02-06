//
//  GLUpdateMessage.swift
//  nRF Mesh
//
//  Created by yan on 20/1/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

class GLUpdateMessage: GLMessage {
    public static var responseType: NordicMesh.StaticMeshResponse.Type {
        return GLUpdateStatus.self
    }
    
    public static var code: UInt32 = 0x3F
        
    public var parameters: Data?
    
    init(value: Bool) {
        self.parameters = Data() + value
    }
}

public struct GLUpdateStatus: GLResponse {
    public static var code: UInt32 = 0x3F
    
    public var parameters: Data?
    
    public let value: Bool
    
    public init?(parameters: Data) {
        self.parameters = parameters
        value = parameters.asUInt8 == 1
    }
    
}
