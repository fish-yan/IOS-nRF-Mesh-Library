//
//  BSceneStoreManager.swift
//  nRF Mesh
//
//  Created by yan on 2024/5/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

class BSceneStoreManager: Observable, ObservableObject {
    @Published var scene: nRFMeshProvision.Scene?
}
