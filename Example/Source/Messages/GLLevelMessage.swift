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
    
    public static var code: UInt32 = 0x3
        
    public var parameters: Data?
    
    init(levels: [UInt8]) {
        self.parameters = levels.reduce(into: Data(), {$0 += $1})
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
