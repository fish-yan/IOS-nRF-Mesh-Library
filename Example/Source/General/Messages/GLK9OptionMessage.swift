//
//  GLK9OptionMessage.swift
//  nRF Mesh
//
//  Created by yan on 20/1/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

class GLK9OptionMessage: GLMessage {
    public static var responseType: NordicMesh.StaticMeshResponse.Type {
        return GLK9OptionStatus.self
    }
    
    public static var code: UInt32 = 0x15
        
    public var parameters: Data?
    
    init(value: String) {
        self.parameters = Data(hex: value)
    }
}

public struct GLK9OptionStatus: GLResponse {
    public static var code: UInt32 = 0x15
    
    public var parameters: Data?
    
    public let value: String
    
    public init?(parameters: Data) {
        self.parameters = parameters
        value = parameters.toHexString()
    }
    
}
