//
//  BScenesView.swift
//  nRF Mesh
//
//  Created by yan on 2024/5/6.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct BScenesView: View {
    @State private var columns = [GridItem(.adaptive(minimum: 170, maximum: 200))]
    @State private var scenes: [nRFMeshProvision.Scene] = []
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns) {
                ForEach(scenes, id: \.self) { model in
                    NavigationLink(value: NavPath.bSceneEditView(scene: model)) {
                        sceneItem(image: model.icon, title: model.name, des: model.detail)
                    }
                }
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 20))
        }
        .navigationTitle("Scenes")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .onAppear(perform: onAppera)
        .toolbar {
            TooBarBackItem()
        }
        .toolbar {
            NavigationLink(value: NavPath.bSceneEditView(scene: nil)) {
                Text("Add scene")
                    .underline()
                    .font(.label)
            }
        }
        .navigationDestination(for: NavPath.self) { target in
            switch target {
            case .bSceneEditView(let scene):
                BSceneEditView(scene: scene)
            default: Text("")
            }
        }
    }
    
    func sceneItem(image: String, title: String, des: String) -> some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(image)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(Color.accent)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                Spacer()
                    .frame(height: 10)
                Text(title)
                    .font(.labelTitle)
                    .foregroundStyle(Color.accent)
                Text(des)
                    .font(.secondaryLabel)
                    .foregroundStyle(Color.secondaryLabel)
                    .frame(height: 35, alignment: .topLeading)
            }
            .multilineTextAlignment(.leading)
            .padding(20)
            .background(Color.tertiaryBackground)
            .clipShape(.rect(cornerRadius: 19))
    }
}


extension BScenesView {
    
    func onAppera() {
        let meshNetwork = MeshNetworkManager.instance.meshNetwork!
        scenes = meshNetwork.scenes
        columns = scenes.count <= 2 ? [GridItem()] : [GridItem(.adaptive(minimum: 170, maximum: 200))]
    }
    
}


#Preview {
    BScenesView()
}
