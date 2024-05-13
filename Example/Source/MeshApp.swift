//
//  MeshApp.swift
//  nRF Mesh
//
//  Created by yan on 2024/4/1.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct MeshApp: App {
    var body: some Scene {
        WindowGroup {
            CTabView()
        }
    }
}

struct RootView: View {
    @StateObject var appManager = AppManager()
    var body: some View {
        Group {
            switch appManager.userRole {
            case .normal:
                CTabView()
                    .transition(.opacity)
            case .supervisor:
                BTabView()
                    .transition(.opacity)
            case .commissioner:
                PRootView()
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .animation(.spring, value: appManager.userRole)
        .environment(appManager)
    }
}

struct PRootView: UIViewControllerRepresentable {
    @EnvironmentObject var appManager: AppManager
    func makeUIViewController(context: Context) -> RootTabBarController {
        let root = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "RootTabBarController") as! RootTabBarController
        root.backCallback = {
            appManager.userRole = .supervisor
        }
        return root
    }
    
    func updateUIViewController(_ uiViewController: RootTabBarController, context: Context) {
        
    }
    
    typealias UIViewControllerType = RootTabBarController
    
    
}
