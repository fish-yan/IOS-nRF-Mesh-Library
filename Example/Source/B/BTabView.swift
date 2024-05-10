//
//  MeshTabView.swift
//  nRF Mesh
//
//  Created by yan on 2024/4/1.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct BTabView: View {
    @StateObject var pathManager = BPathManager()
    @StateObject var sceneStoreManager = BSceneStoreManager()
    var body: some View {
        NavigationStack(path: $pathManager.path) {
            VStack(spacing: 0) {
                switch pathManager.selectedTab {
                case 0:
                    BScenesView()
                case 1:
                    BSetView()
                default: Text("a")
                }
                tabbar()
            }
            .background(Color.groupedBackground)
        }
        .environment(pathManager)
        .environment(sceneStoreManager)
        .tint(.primary)
    }
    
    func tabbar() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(.tabBar)
                .ignoresSafeArea()
            HStack {
                tabItem(title: "Scene", image: .icTabMainNormal, selectedImage :.icTabMainSelected, tag: 0)
                tabItem(title: "Set", image: .icTabLightsNormal, selectedImage: .icTabLightsSelected, tag: 1)
            }
        }
        .frame(height: 48)
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: -3)
    }
    
    func tabItem(title: String, image: ImageResource, selectedImage: ImageResource, tag: Int) -> some View {
        VStack {
            Spacer()
                .frame(height: 10)
            Image(pathManager.selectedTab == tag ? selectedImage : image)
            Spacer()
                .frame(height: 5)
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(pathManager.selectedTab == tag ? Color.primary : Color.secondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .gesture(TapGesture().onEnded({ _ in
            pathManager.selectedTab = tag
        }))
    }
}

#Preview {
    BTabView()
}
