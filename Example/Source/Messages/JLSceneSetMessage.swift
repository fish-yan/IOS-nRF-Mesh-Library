//
//  JLSceneSetMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct JLSceneSetMessage: JLMessage {
    
    public static var code: UInt32 = 0x4
        
    public var parameters: Data?
    
    init(scene: Int16) {
        self.parameters = Data() + scene
    }
}

public struct JLSceneSetStatus: JLResponse {
    public static var code: UInt32 = 0x4
    
    public var parameters: Data?
    
    public let scene: Int16
    
    public init?(parameters: Data) {
        self.parameters = parameters
        scene = Int16(parameters.asUInt16)
    }
    
}
