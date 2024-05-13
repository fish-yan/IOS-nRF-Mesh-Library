//
//  MeshTabView.swift
//  nRF Mesh
//
//  Created by yan on 2024/4/1.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct BTabView: View {
    @EnvironmentObject var appManager: AppManager
    var body: some View {
        NavigationStack(path: $appManager.b.path) {
            VStack(spacing: 0) {
                switch appManager.b.selectedTab {
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
            Image(appManager.b.selectedTab == tag ? selectedImage : image)
            Spacer()
                .frame(height: 5)
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(appManager.b.selectedTab == tag ? Color.primary : Color.secondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .gesture(TapGesture().onEnded({ _ in
            appManager.b.selectedTab = tag
        }))
    }
}

#Preview {
    BTabView()
}
