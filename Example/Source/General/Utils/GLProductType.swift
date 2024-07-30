//
//  GLProductId.swift
//  nRF Mesh
//
//  Created by yan on 2024/7/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

enum GLProductType: UInt16 {
    case dimmer = 0x1 // GL dimmer
    case pushButton = 0x2 // GL Push button
    case sceneTouchPad = 0x3 // GL Scene Touch Pad
    case gatewayModbus = 0x4 // GL Gateway Modbus
    case GatewabBeacon = 0x5 // GL Gateway Beacon
    case modbusClient = 0x6 // GL Modbus Client
    case dongle = 0x7 // Dongle UART
    case arcoSchedule = 0x8 // ArcoSchedule
    case BX10 = 0x9 // BX10
    case modbusFall = 0xA // Modbus Fall
    case arcoSenceBeacon = 0x10 // ArcoSence + Beacon
    case arcoSenceOutdoorBeacon = 0x11 // ArcoSence Outdoor + Beacon
    case arcoSpace = 0x12 // ArcoSpace
    case arcoSpaceABC = 0x13 // ArcoSpace ABC
    case arcoSpaceRGBW = 0x14 // ArcoSpace RGBW
    
    var isLight: Bool {
        rawValue >= 0x10 && rawValue <= 0x14
    }
}
