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
    
    private var messageManager = MeshMessageManager()
    
    init(node: Node) {
        self.node = node
    }
    init(zone: GLZone) {
        self.zone = zone
    }
    
    var body: some View {
        List {
            Section {
                NavigationLink(value: NavPath.bSceneEditView(scene: nil)) {
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
            TooBarBackItem()
        }
        .toolbar {
            Button("Save", action: storeScene)
            .disabled(selectedScene < 1)
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(for: NavPath.self) { target in
            switch target {
            case .bSceneEditView:
                BSceneEditView(scene: nil, node: node, zone: zone)
            default: Text("")
            }
        }
    }
}

private extension BSceneStoreView {
    func onAppear() {
        let meshNetwork = MeshNetworkManager.instance.meshNetwork!
        if let node {
            storedScenes = node.scenes
        } else if let zone {
            let address = UInt16(zone.zone) * 16 + 0xD000
            if let group = meshNetwork.group(withAddress: MeshAddress(address)) {
                storedScenes = group.scenes
            }
        }
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
        } else if let zone {
            let address = UInt16(zone.zone) * 16 + 0xD000
            if let group = MeshNetworkManager.instance.meshNetwork!.group(withAddress: MeshAddress(address)) {
                _ = try? MeshNetworkManager.instance.send(message, to: group)
            }
        }
    }
}

extension BSceneStoreView: MeshMessageDelegate {
    func meshNetworkManager(_ manager: NordicMesh.MeshNetworkManager, didReceiveMessage message: NordicMesh.MeshMessage, sentFrom source: NordicMesh.Address, to destination: NordicMesh.MeshAddress) {
        switch message {
        case _ as SceneRegisterStatus:
            appManager.b.path.removeLast()
        default: break
        }
    }
}
