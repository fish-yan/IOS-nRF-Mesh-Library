//
//  GLK9ConnectMessage.swift
//  nRF Mesh
//
//  Created by yan on 20/1/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

class GLK9ConnectMessage: GLMessage {
    public static var responseType: NordicMesh.StaticMeshResponse.Type {
        return GLControlStatus.self
    }
    
    public static var code: UInt32 = 0x14
        
    public var parameters: Data?
    
    init(number: UInt8) {
        self.parameters = Data() + number
    }
}
