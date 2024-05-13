//
//  LightStoreSceneView.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct LightStoreSceneView: View {
    @Environment(\.dismiss) var dismiss;
    var node: Node?
    var group: NordicMesh.Group?
    
    @State var storedScenes: [NordicMesh.Scene] = []
    @State var newScenes: [NordicMesh.Scene] = []
    
    @Binding var selected: SceneNumber
    
    @State var selectedScene: SceneNumber = 0
    
    private var messageManager = MeshMessageManager()
    
    init(node: Node, selectedScene: Binding<SceneNumber>) {
        self.node = node
        _selected = selectedScene
    }
    
    init(group: NordicMesh.Group, selectedScene: Binding<SceneNumber>) {
        self.group = group
        _selected = selectedScene
    }
    
    var body: some View {
        List {
            Section {
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
            } footer: {
                Text("Each node may store up to 16 scenes")
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
            } footer: {
                Text("Selecting a scene from above will overwrite its previously associated state")
            }
        }
        .navigationTitle("Store Scene")
        .onAppear(perform: onAppear)
        .toolbar {
            Button("Save") {
                storeScene()
            }
            .disabled(selectedScene < 1)
        }
    }
}

private extension LightStoreSceneView {
    func onAppear() {
        if let node {
            storedScenes = node.scenes
        } else if let group {
            storedScenes = group.scenes
        }
        
        let meshNetwork = MeshNetworkManager.instance.meshNetwork!
        newScenes = meshNetwork.customScenes.filter { !storedScenes.contains($0) }
        messageManager.delegate = self
    }
    
    func storeScene() {
        let message = SceneStore(selectedScene)
        if let node {
            guard let sceneSetupModel = node.sceneSetupModel else {
                return
            }
            _ = try? MeshNetworkManager.instance.send(message, to: sceneSetupModel)
        } else if let group {
            _ = try? MeshNetworkManager.instance.send(message, to: group)
        }
    }
}

extension LightStoreSceneView: MeshMessageDelegate {
    func meshNetworkManager(_ manager: NordicMesh.MeshNetworkManager, didReceiveMessage message: NordicMesh.MeshMessage, sentFrom source: NordicMesh.Address, to destination: NordicMesh.MeshAddress) {
        switch message {
        case _ as SceneRegisterStatus:
            selected = selectedScene
            dismiss.callAsFunction()
        default: break
        }
    }
    
}
