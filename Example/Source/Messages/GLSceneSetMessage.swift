//
//  GLSceneSetMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct GLSceneSetMessage: GLMessage {
    
    public static var code: UInt32 = 0x4
        
    public var parameters: Data?
    
    init(scene: UInt8) {
        self.parameters = Data() + scene
    }
}

public struct GLSceneSetStatus: GLResponse {
    public static var code: UInt32 = 0x4
    
    public var parameters: Data?
    
    public let scene: UInt8
    
    public init?(parameters: Data) {
        self.parameters = parameters
        scene = parameters.asUInt8
    }
    
}
