//
//  GlobalConfig.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/18.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

struct GlobalConfig {
    static func transitionTime(_ isOn: Bool) -> TransitionTime {
        let steps = isOn ? LocalStorage.onTransitionSteps : LocalStorage.offTransitionSteps
        return TransitionTime(steps: steps, stepResolution: .seconds)
    }
    static func delay(_ isOn: Bool) -> UInt8 {
        isOn ? LocalStorage.onDelay : LocalStorage.offDelay
    }
    
    static var userRole: UserRole {
        UserRole(rawValue: LocalStorage.userRole) ?? .normal
    }
       
    static var level0: Double {
        LocalStorage.level0
    }
    static var level1: Double {
        LocalStorage.level1
    }
    static var level2: Double {
        LocalStorage.level2
    }
    static var level3: Double {
        LocalStorage.level3
    }

}

enum UserRole: String, CaseIterable {
    case normal
    case supervisor
    case commissioner
}
