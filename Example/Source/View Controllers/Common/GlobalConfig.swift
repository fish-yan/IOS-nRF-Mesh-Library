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
}
