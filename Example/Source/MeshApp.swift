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

extension Text {
    init(_ key: String) {
        self.init(LocalizedStringKey(key))
    }
}

struct RootView: View {
    @StateObject var appManager = AppManager.manager
    var body: some View {
        ProTabView()
        .animation(.spring, value: appManager.userRole)
        .environment(appManager)
        .environment(\.locale, .init(identifier: appManager.language.rawValue))
        .onAppear {
            NotificationCenter.default.addObserver(forName: .languageChanged, object: nil, queue: .main) { no in
                appManager.userRole = .empty
                Task {
                    try? await Task.sleep(nanoseconds:1000_000_000)
                    appManager.userRole = .commissioner
                }
//                appManager.userRole = .commissioner
            }
        }
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
