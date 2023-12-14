//
//  GLCoordinateMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct GLCoordinateMessage: GLMessage {
    public static var responseType: nRFMeshProvision.StaticMeshResponse.Type {
        return GLCoordinateStatus.self
    }
    
    public static var code: UInt32 = 0x11
        
    public var parameters: Data?
    
    init(coordinate: (z: UInt8, x: UInt8, y: UInt8)) {
        self.parameters = Data() + coordinate.z + coordinate.x + coordinate.y
    }
}

public struct GLCoordinateStatus: GLResponse {
    public static var code: UInt32 = 0x11
    
    public var parameters: Data?
    
    public let coordinate: (z: UInt8, x: UInt8, y: UInt8)
    
    public init?(parameters: Data) {
        self.parameters = parameters
        coordinate = (z: parameters.read(fromOffset: 0), x: parameters.read(fromOffset: 1), y: parameters.read(fromOffset: 2))
    }
}
