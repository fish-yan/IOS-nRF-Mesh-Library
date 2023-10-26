//
//  AiMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/24.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct LuminaireAiMessage: LuminaireMessage {
    
    public static var code: UInt32 = 0x13
        
    public var parameters: Data?
    
    init(status: LuminaireSimpleStatus) {
        self.parameters = Data() + Int16(status.rawValue)
    }
}

public struct LuminaireAiStatus: LuminaireResponse {
    public static var code: UInt32 = 0x13
    
    public var parameters: Data?
    
    public let status: LuminaireSimpleStatus
    
    public init?(parameters: Data) {
        self.parameters = parameters
        let raw = Int(parameters.toHexString(), radix: 16) ?? 0
        status = LuminaireSimpleStatus(rawValue: raw) ?? .off
    }
    
}
