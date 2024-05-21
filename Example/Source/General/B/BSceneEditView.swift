//
//  BSceneEditView.swift
//  nRF Mesh
//
//  Created by yan on 2024/5/7.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct BSceneEditView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var sceneStoreManager: BSceneStoreManager
    
    private let scene: NordicMesh.Scene?
    @State private var nameText: String = ""
    @State private var describeText: String = "Personalised Lighting Modes"
    @State private var numberText: String = ""
    
    private var title: String = ""
    @State private var sceneNumber: SceneNumber = 0x0
    
    @State private var isPresented: Bool = false
    @State private var isDeleteSceneAlert: Bool = false
    private var messageManager = MeshMessageManager()
    private let taskManager = MeshTaskManager()
    
    var zone: GLZone?
    var node: Node?
    
    init(scene: NordicMesh.Scene? = nil, node: Node? = nil, zone: GLZone? = nil) {
        self.scene = scene
        self.zone = zone
        self.node = node
        title = scene == nil ? "New Scene" : "Modifying Scene"
    }
    
    var body: some View {
        VStack(spacing: 10) {
            InputItemView(title: "Name", placehoder: "Scene name", text: $nameText)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            InputItemView(title: "Decribe", placehoder: "Scene description", text: $describeText)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            InputItemView(title: "Number", placehoder: "Scene number", text: $numberText)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(true)
            Spacer()
                .frame(height: 50)
            Button(action: saveAction, label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.black.opacity(nameText.isEmpty ? 0.3 : 1))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            })
            .disabled(nameText.isEmpty)
            
            Button(action: {
                hideKeyboard()
                if let scene {
                    if scene.isUsed {
                        isDeleteSceneAlert = true
                    } else {
                        try? MeshNetworkManager.instance.meshNetwork?.remove(scene: scene.number)
                        MeshNetworkManager.instance.saveAll()
                        appManager.b.path.removeLast()
                    }
                } else {
                    appManager.b.path.removeLast()
                }
            }, label: {
                Text(scene == nil ? "Cancel" : "Delete")
                    .foregroundStyle(scene == nil ? .black : .red)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke()
                    }
            })
            Spacer()
        }
        .padding(20)
        .navigationTitle(title)
        .toolbar {
            TooBarBackItem()
        }
        .background(Color.secondaryBackground)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard)
        .alert("Remind", isPresented: $isPresented, actions: {
            Button(role: .cancel) {
                appManager.b.path.removeLast()
            } label: {
                Text("Cancel")
            }
            Button("Continue") {
                appManager.b.path.removeAll()
                appManager.b.selectedTab = 1
            }
        }, message: {
            Text("Select light or zone to continue setting the scene?")
        })
        .alert("Warning", isPresented: $isDeleteSceneAlert, actions: {
            Button("Cancel", role: .cancel, action: {})
            Button(role: .destructive) {
                if let scene {
                    scene.addresses.forEach { address in
                        taskManager.append(.deleteScene(scene.number, to: address))
                    }
                }
                executeNext()
                Loading.show()
            } label: {
                Text("Delete")
            }
        }, message: {
            Text("This scene is in use, delete or not?")
        })
        .onAppear(perform: onAppear)
        .loadingable()
    }
}

private extension BSceneEditView {
    func onAppear() {
        if let scene {
            nameText = scene.name
            describeText = scene.detail
            sceneNumber = scene.number
            numberText = "0x" + String(scene.number, radix: 16)
        } else {
            sceneNumber = MeshNetworkManager.instance.meshNetwork?.nextAvailableScene() ?? 0
            numberText = "0x" + String(sceneNumber, radix: 16)
        }
        messageManager.delegate = self
    }
    
    func saveAction() {
        hideKeyboard()
        let meshNetwork = MeshNetworkManager.instance.meshNetwork!
        if let scene {
            scene.name = nameText
            scene.detail = describeText
        } else {
            try? meshNetwork.add(scene: sceneNumber, name: nameText, detail: describeText)
        }
        MeshNetworkManager.instance.saveAll()
        storeScene()
    }
    
    func storeScene() {
        let message = SceneStore(sceneNumber)
        if let node {
            guard let sceneSetupModel = node.sceneSetupModel else {
                return
            }
            _ = try? MeshNetworkManager.instance.send(message, to: sceneSetupModel)
            appManager.b.path.removeAll()
        } else if let zone {
            let address = UInt16(zone.zone) * 16 + 0xD000
            if let group = MeshNetworkManager.instance.meshNetwork!.group(withAddress: MeshAddress(address)) {
                _ = try? MeshNetworkManager.instance.send(message, to: group)
            }
            appManager.b.path.removeAll()
        } else {
            isPresented = true
        }
    }
    
    func executeNext() {
        guard let task = taskManager.nextTask else {
            completed()
            return
        }
        taskManager.update(status: .inProgress)
        let manager = MeshNetworkManager.instance
        switch task {
        case .deleteScene(let scene, let address):
            guard let node = manager.meshNetwork!.node(withAddress: address),
            let model = node.sceneSetupModel else {
                return
            }
            _ = try? manager.send(SceneDelete(scene), to: model)
        default: break
        }
    }
    
    func completed() {
        Loading.hidden()
        guard let scene else { return }
        try? MeshNetworkManager.instance.meshNetwork?.remove(scene: scene.number)
        MeshNetworkManager.instance.saveAll()
        appManager.b.path.removeLast()
    }
}


extension BSceneEditView: MeshMessageDelegate {
    func meshNetworkManager(_ manager: NordicMesh.MeshNetworkManager, didReceiveMessage message: NordicMesh.MeshMessage, sentFrom source: NordicMesh.Address, to destination: NordicMesh.MeshAddress) {
        if let _ = taskManager.task {
            taskManager.update(status: .success)
            executeNext()
        }
    }
}

#Preview {
    BSceneEditView()
        .background(Color.secondaryBackground)
}
