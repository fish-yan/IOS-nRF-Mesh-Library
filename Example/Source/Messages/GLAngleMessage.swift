//
//  AngleMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

public struct GLAngleMessage: GLMessage {
    public static var responseType: NordicMesh.StaticMeshResponse.Type {
        return GLAngleStatus.self
    }
    
    public static var code: UInt32 = 0x11
        
    public var parameters: Data?
    
    init(angle: UInt8) {
        self.parameters = Data() + angle
    }
}

public struct GLAngleStatus: GLResponse {
    public static var code: UInt32 = 0x11
    
    public var parameters: Data?
    
    public let angle: UInt8
    
    public init?(parameters: Data) {
        self.parameters = parameters
        angle = UInt8(parameters.toHexString(), radix: 16) ?? 0
    }
    
}
