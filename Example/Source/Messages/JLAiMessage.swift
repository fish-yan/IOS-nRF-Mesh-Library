//
//  AiMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/24.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct JLAiMessage: JLMessage {
    
    public static var code: UInt32 = 0x13
        
    public var parameters: Data?
    
    init(status: JLSimpleStatus) {
        self.parameters = Data() + Int16(status.rawValue)
    }
}

public struct JLAiStatus: JLResponse {
    public static var code: UInt32 = 0x13
    
    public var parameters: Data?
    
    public let status: JLSimpleStatus
    
    public init?(parameters: Data) {
        self.parameters = parameters
        let raw = Int(parameters.toHexString(), radix: 16) ?? 0
        status = JLSimpleStatus(rawValue: raw) ?? .off
    }
    
}
