//
//  GLLevelMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct GLLevelMessage: GLMessage {
    public static var responseType: nRFMeshProvision.StaticMeshResponse.Type {
        return GLLevelStatus.self
    }
    
    public static var code: UInt32 = 0x3
        
    public var parameters: Data?
    
    public var levels: [UInt8]
    
    init(levels: [UInt8]) {
        self.parameters = levels.reduce(into: Data(), {$0 += $1})
        self.levels = levels
    }
}

public struct GLLevelStatus: GLResponse {
    public static var code: UInt32 = 0x3
    
    public var parameters: Data?
    
    public let levels: [UInt8]
    
    public init?(parameters: Data) {
        self.parameters = parameters
        levels = parameters.bytes
    }
    
}
