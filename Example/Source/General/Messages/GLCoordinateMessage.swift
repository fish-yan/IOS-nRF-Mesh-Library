//
//  GLCoordinateMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

public struct GLCoordinateMessage: GLMessage {
    public static var responseType: NordicMesh.StaticMeshResponse.Type {
        return GLCoordinateStatus.self
    }
    
    public static var code: UInt32 = 0x11
        
    public var parameters: Data?
    
    init(coordinate: String) {
        self.parameters = Data(hex: coordinate)
    }
}

public struct GLCoordinateStatus: GLResponse {
    public static var code: UInt32 = 0x11
    
    public var parameters: Data?
    
    public let coordinate: String
    
    public init?(parameters: Data) {
        self.parameters = parameters
        coordinate = parameters.toHexString()
    }
}
