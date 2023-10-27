//
//  JLFadeTimeMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct JLFadeTimeMessage: JLMessage {
    
    public static var code: UInt32 = 0x2
        
    public var parameters: Data?
    
    init(time: Int) {
        let hex = String(format: "%04d", time)
        self.parameters = Data(hex: hex)
    }
}

public struct JLFadeTimeStatus: JLResponse {
    public static var code: UInt32 = 0x2
    
    public var parameters: Data?
    
    public let time: Int
    
    public init?(parameters: Data) {
        self.parameters = parameters
        time = Int(parameters.toHexString()) ?? 0
    }
}
