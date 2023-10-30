//
//  ScenesListView.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/9.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct ScenesListView: View {
    @State private var scenes = MeshNetworkManager.instance.meshNetwork?.scenes ?? []
    @State private var isShowSetting = false
    @ObservedObject var meshNetworkModel = GLMeshNetworkModel.instance
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        
                    } label: {
                        ItemView(resource: .groupSceneOutline, title: "Arco Sense", detail: "General Luminaire")
                    }
                    NavigationLink {
                        
                    } label: {
                        ItemView(resource: .groupSceneOutline, title: "Arco Space", detail: "General Luminaire")
                    }
                }
                Section {
                    ForEach(scenes, id: \.number) { scene in
                        HStack {
                            ItemView(resource: .groupSceneOutline, title: scene.name, detail: "Number: \(scene.number)")
                            Spacer()
                            Button {
                                meshNetworkModel.selectedScene = scene.number
                                MeshNetworkManager.instance.saveModel()
                            } label: {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                                    .opacity(meshNetworkModel.selectedScene == scene.number ? 1 : 0)
                            }

                        }
                    }
                }
            }
            .navigationTitle("Scenes")
            .toolbar {
                NavigationLink(destination: ScenesManagerView()) {
                    Image(systemName: "gearshape")
                }
                .opacity(isShowSetting ? 1 : 0)
            }
            .onAppear {
                scenes = MeshNetworkManager.instance.meshNetwork?.scenes ?? []
                isShowSetting = GlobalConfig.isShowSetting
            }
        }
    }
}

#Preview {
    ScenesListView()
}
