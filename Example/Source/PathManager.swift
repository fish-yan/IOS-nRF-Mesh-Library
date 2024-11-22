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
    @Published var c = PathManager()
    @Published var b = PathManager()
    @Published var p = PathManager()
    @Published var userRole: UserRole = .normal
    private static var defaultLanguage: AppLanguage {
        if let lan = Locale.preferredLanguages.first {
            return AppLanguage(rawValue: lan)
        }
        return .en
    }
    @AppStorage("AppLanguage") var language = AppManager.defaultLanguage
    
    @AppStorage("MeshAnglePercent") var anglePercents: [Double] = [0, 0.57, 0.69, 0.74, 0.79, 0.85, 0.93]
    
    let angles = [13, 18, 24, 30, 36, 42, 50]
    
    private var canyCancellable: AnyCancellable?
    private var banyCancellable: AnyCancellable?
    private var panyCancellable: AnyCancellable?
    
    static let manager = AppManager()
    
    private init() {
        canyCancellable = self.c.objectWillChange.sink {
            self.objectWillChange.send()
        }
        banyCancellable = self.b.objectWillChange.sink {
            self.objectWillChange.send()
        }
        panyCancellable = self.p.objectWillChange.sink {
            self.objectWillChange.send()
        }
    }
}

class PathManager: Observable, ObservableObject {
    @Published var path: [NavPath] = []
    @Published var selectedTab: Int = 0
    
    func pop() {
        if path.isEmpty {
            return
        }
        path.removeLast()
    }
    
    func popToRoot() {
        if path.isEmpty {
            return
        }
        path.removeAll()
    }
}

enum NavPath: Hashable {
    case cLightView(node: Node)
    case bZoneView(zone: GLZone)
    case bSceneEditView(scene: NordicMesh.Scene?)
    case bSceneStoreNodeView(node: Node)
    case bSceneStoreZoneView(zone: GLZone)
    case bStoreSceneEditView(node: Node?, group: GLZone?)
    case pZoneDetail(zone: GLZone?)
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
