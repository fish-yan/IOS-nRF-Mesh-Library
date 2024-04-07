//
//  PathManager.swift
//  nRF Mesh
//
//  Created by yan on 2024/4/1.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

class PathManager: Observable, ObservableObject {
    @Published var path: [NavPath] = []
}

enum NavPath: Hashable {
    case cLightView(node: Node)
}
