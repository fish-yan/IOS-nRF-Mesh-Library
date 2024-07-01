//
//  LightStoreSceneView.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct BSceneStoreView: View {
    @EnvironmentObject private var appManager: AppManager
    var node: Node?
    var zone: GLZone?
    
    @State private var storedScenes: [NordicMesh.Scene] = []
    @State private var newScenes: [NordicMesh.Scene] = []
    
    @State private var selectedScene: SceneNumber = 0
        
    init(node: Node) {
        self.node = node
    }
    init(zone: GLZone) {
        self.zone = zone
    }
    
    var body: some View {
        List {
            Section {
                NavigationLink(value: NavPath.bStoreSceneEditView(node: node, group: zone)) {
                    Text("Create a new scene")
                }
                ForEach(newScenes, id: \.number) { scene in
                    HStack {
                        Text(scene.name)
                        Spacer()
                        Button {
                            selectedScene = scene.number
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.headline)
                                .opacity(selectedScene == scene.number ? 1 : 0)
                        }
                    }
                }
            } header: {
                Text("New Scenes")
            }
            
            Section {
                ForEach(storedScenes, id: \.number) { scene in
                    HStack {
                        Text(scene.name)
                        Spacer()
                        Button {
                            selectedScene = scene.number
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.headline)
                                .opacity(selectedScene == scene.number ? 1 : 0)
                        }
                    }
                }
            } header: {
                Text("Stored")
            }
        }
        .navigationTitle("Store Scene")
        .onAppear(perform: onAppear)
        .toolbar {
            TooBarBackItem()
        }
        .toolbar {
            Button("Save", action: storeScene)
            .disabled(selectedScene < 1)
            .underline()
        }
        .navigationBarBackButtonHidden()
    }
}

private extension BSceneStoreView {
    func onAppear() {
        let meshNetwork = MeshNetworkManager.instance.meshNetwork!
        if let node {
            storedScenes = node.scenes
        } else if let zone {
            storedScenes = zone.scenes()
        }
        newScenes = meshNetwork.customScenes.filter { !storedScenes.contains($0) }
    }
    
    func storeScene() {
        let message = SceneStoreUnacknowledged(selectedScene)
        if let node {
            guard let sceneSetupModel = node.sceneSetupModel else {
                return
            }
            _ = try? MeshNetworkManager.instance.send(message, to: sceneSetupModel)
            appManager.b.path.removeAll()
        } else if let zone {
            let address = UInt16(zone.number) * 16 + 0xD000
            let group = try! NordicMesh.Group(name: "", address: MeshAddress(address))
            _ = try? MeshNetworkManager.instance.send(message, to: group)
            appManager.b.path.removeAll()
        }
    }
}
