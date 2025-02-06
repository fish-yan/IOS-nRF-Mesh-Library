//
//  GLK9ControlMessage.swift
//  nRF Mesh
//
//  Created by yan on 20/1/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

class GLK9ControlMessage: GLMessage {
    public static var responseType: NordicMesh.StaticMeshResponse.Type {
        return GLK9ControlStatus.self
    }
    
    public static var code: UInt32 = 0x16
        
    public var parameters: Data?
    
    init(value: String) {
        self.parameters = Data(hex: value)
    }
}

public struct GLK9ControlStatus: GLResponse {
    public static var code: UInt32 = 0x16
    
    public var parameters: Data?
    
    public let value: String
    
    public init?(parameters: Data) {
        self.parameters = parameters
        value = parameters.toHexString()
    }
    
}
