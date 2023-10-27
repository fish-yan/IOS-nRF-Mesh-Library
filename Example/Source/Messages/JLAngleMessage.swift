//
//  AngleMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct JLAngleMessage: JLMessage {
    
    public static var code: UInt32 = 0x11
        
    public var parameters: Data?
    
    init(angle: Int16) {
        self.parameters = Data() + angle
    }
}

public struct JLAngleStatus: JLResponse {
    public static var code: UInt32 = 0x11
    
    public var parameters: Data?
    
    public let angle: Int16
    
    public init?(parameters: Data) {
        self.parameters = parameters
        angle = Int16(parameters.toHexString(), radix: 16) ?? 0
    }
    
}
