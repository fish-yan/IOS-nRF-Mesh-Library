//
//  JLCoordinateMessage.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/26.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

public struct JLCoordinateMessage: JLMessage {
    
    public static var code: UInt32 = 0x11
        
    public var parameters: Data?
    
    init(coordinate: (z: Int16, x: Int16, y: Int16)) {
        self.parameters = Data() + coordinate.z + coordinate.x + coordinate.y
    }
}

public struct JLCoordinateStatus: JLResponse {
    public static var code: UInt32 = 0x11
    
    public var parameters: Data?
    
    public let coordinate: (z: Int16, x: Int16, y: Int16)
    
    public init?(parameters: Data) {
        self.parameters = parameters
        coordinate = (z: parameters.read(fromOffset: 0), x: parameters.read(fromOffset: 1), y: parameters.read(fromOffset: 2))
    }
}
