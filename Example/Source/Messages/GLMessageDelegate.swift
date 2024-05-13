//
//  GLMessageDelegate.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/24.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

fileprivate let companyId: Int16 = 0x0841

public protocol GLMessage: StaticAcknowledgedVendorMessage {
    static var code: UInt32 { get }
}

extension GLMessage {
    public static var opCode: UInt32 { (UInt32(0xC0 | code) << 16) | UInt32(companyId.bigEndian) }

    public init?(parameters: Data) {
        return nil
    }
}

public protocol GLResponse: StaticMeshResponse {
    static var code: UInt32 { get }
}

extension GLResponse {
    public static var opCode: UInt32 { (UInt32(0xC0 | code) << 16) | UInt32(companyId.bigEndian) }
}

public enum GLSimpleStatus: Int {
    case off = 0
    case on = 1
    case read = 2
    
    public init(bool: Bool) {
        self.init(rawValue: bool ? 1 : 0)!
    }
}

extension Data {
    var asUInt8: UInt8 {
        return self[0]
    }
    
    func prePad(_ count: Int) -> Data {
        Data(repeating: 0, count: (Swift.max(0, count - self.count))) + self
    }
}

let jlResponseTypes: [GLResponse.Type] = [
    GLColorTemperatureStatus.self,
    GLAngleStatus.self,
    GLAiStatus.self,
    GLSensorStatus.self,
    GLLevelStatus.self,
    GLRunTimeStatus.self,
    GLFadeTimeStatus.self,
    GLCoordinateStatus.self,
    GLSceneSetStatus.self,
    GLGlobalOnOffStatus.self,
    GLRelayStatus.self,
    GLBeaconOnOffStatus.self,
    GLBeaconTimeIntervalStatus.self,
    GLBeaconRSSIStatus.self,
    GLBeaconUUIDSetStatus.self
]
