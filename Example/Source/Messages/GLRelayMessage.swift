//
//  GLRelayMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

public struct GLRelayMessage: GLMessage {
    public static var responseType: NordicMesh.StaticMeshResponse.Type {
        return GLRelayStatus.self
    }
    
    public static var code: UInt32 = 0x10
        
    public var parameters: Data?
    
    init(levels: [Int16]) {
        self.parameters = levels.reduce(Data(), +)
    }
}

public struct GLRelayStatus: GLResponse {
    public static var code: UInt32 = 0x10
    
    public var parameters: Data?
    
    public let levels: [Int16]
    
    public init?(parameters: Data) {
        self.parameters = parameters
        levels = parameters.bytes.map({Int16($0)})
    }
    
}
