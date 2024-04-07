//
//  MeshTabView.swift
//  nRF Mesh
//
//  Created by yan on 2024/4/1.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct MeshTabView: View {
    @StateObject var pathManager = PathManager()
    @State var selection = 0
    var body: some View {
        NavigationStack(path: $pathManager.path) {
            VStack(spacing: 0) {
                switch selection {
                case 0:
                    CScenesPageView()
                case 1:
                    CLightListView()
                default: Text("a")
                }
                tabbar()
            }
            .background(Color.groupedBackground)
        }
        .environment(pathManager)
    }
    
    func tabbar() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(.tabBar)
                .ignoresSafeArea()
            HStack {
                tabItem(title: "Main", image: .icTabMainNormal, selectedImage :.icTabMainSelected, tag: 0)
                tabItem(title: "Lights", image: .icTabLightsNormal, selectedImage: .icTabLightsSelected, tag: 1)
            }
        }
        .frame(height: 48)
        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: -3)
    }
    
    func tabItem(title: String, image: ImageResource, selectedImage: ImageResource, tag: Int) -> some View {
        VStack {
            Spacer()
                .frame(height: 10)
            Image(selection == tag ? selectedImage : image)
            Spacer()
                .frame(height: 5)
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(selection == tag ? Color.primary : Color.secondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .gesture(TapGesture().onEnded({ _ in
            selection = tag
        }))
    }
}

#Preview {
    MeshTabView()
}
