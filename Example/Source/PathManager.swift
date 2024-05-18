//
//  PathManager.swift
//  nRF Mesh
//
//  Created by yan on 2024/4/1.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh
import Combine

class AppManager: Observable, ObservableObject {
    @Published var c = CPathManager()
    @Published var b = CPathManager()
    @Published var userRole: UserRole = .normal
    
    private var anyCancellable: AnyCancellable?
    init() {
        anyCancellable = self.c.objectWillChange.sink {
            self.objectWillChange.send()
        }
        anyCancellable = self.b.objectWillChange.sink {
            self.objectWillChange.send()
        }
    }
}

class CPathManager: Observable, ObservableObject {
    @Published var path: [NavPath] = []
    @Published var selectedTab: Int = 0
}

class BPathManager: Observable, ObservableObject {
    @Published var path: [NavPath] = []
    @Published var selectedTab: Int = 0
}

enum NavPath: Hashable {
    case cLightView(node: Node)
    case bZoneView(zone: GLZone)
    case bSceneEditView(scene: NordicMesh.Scene?)
    case bSceneStoreNodeView(node: Node)
    case bSceneStoreZoneView(zone: GLZone)
    case bStoreSceneEditView(node: Node?, group: GLZone?)
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
