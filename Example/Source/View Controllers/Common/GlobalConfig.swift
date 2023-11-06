//
//  GlobalConfig.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/18.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

class GlobalConfig: ObservableObject {
    
    private init() { }
    
    @AppStorage("userRole") static var userRole: Int = 0
    @AppStorage("onTransitionSteps") static var onTransition: Int = 0
    @AppStorage("offTransitionSteps") static var offTransition: Int = 0
    @AppStorage("onDelay") static var onDelay: Int = 0
    @AppStorage("offDelay") static var offDelay: Int = 0
    @AppStorage("level0") static var level0: Double = 100
    @AppStorage("level1") static var level1: Double = 75
    @AppStorage("level2") static var level2: Double = 50
    @AppStorage("level3") static var level3: Double = 25
    
    @AppStorage("cct0") static var cct0: Double = 25
    @AppStorage("cct1") static var cct1: Double = 50
    @AppStorage("cct2") static var cct2: Double = 75
    @AppStorage("cct3") static var cct3: Double = 100
    
    static var isShowSetting: Bool {
        (UserRole(rawValue: userRole) ?? .normal) != .normal
    }
    
    static var isShowAdvance: Bool {
        (UserRole(rawValue: userRole) ?? .normal) == .commissioner
    }
}

enum UserRole: Int, CaseIterable {
    case normal = 0
    case supervisor = 1
    case commissioner = 2
    
    var string: String {
        switch self {
        case .normal: "normal"
        case .supervisor: "supervisor"
        case .commissioner: "commissioner"
        }
    }
}
