//
//  GroupElementManagerView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/24.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct GroupElementManagerView: View {
    var group: nRFMeshProvision.Group
    private var messageManager = MeshMessageManager()
    @ObservedObject var store = MessageDetailStore()
    
    @State var isDone = false
    
    @State var nodes: Set<Node> = []
    
    init(group: nRFMeshProvision.Group) {
        self.group = group
    }
    
    var body: some View {
        List {
            let hiddenAdd = MeshNetworkManager.defaultGroupAddresses.contains(where: {$0 == group.address.address})
            if !hiddenAdd {
                Section {
                    NavigationLink {
                        LightSelectedView(multiSelected: nodes, originSelected: nodes) { changes in
                            subscribe(nodes: changes.add)
                            unsubscribe(nodes: changes.delete)
                        }
                    } label: {
                        Text("Add Lights")
                    }
                } header: {
                    Text("Add light to group")
                }
            }
            Section {
                SliderView("L0", value: $store.level0)
                SliderView("L1", value: $store.level1)
                SliderView("L2", value: $store.level2)
                SliderView("L3", value: $store.level3)
                HStack {
                    Spacer()
                    Button("send", action: glLevelsSet)
                }
            } header: {
                Text("General Luminaire Level")
            }
            
            Section {
                SliderView("run time", value: $store.runTime, in: 0...900, unit: "s", onDragEnd: runtimeSet)
                SliderView("fade time", value: $store.fadeTime, in: 0...60, unit: "s", onDragEnd: fadetimeSet)
            }
            Section {
                ForEach(store.scenes, id: \.number) { scene in
                    HStack {
                        Text(scene.name)
                        Spacer()
                        Button {
                            sceneSet(scene)
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.headline)
                                .opacity(store.selectedScene == scene.number ? 1 : 0)
                        }
                    }
                }
                .onDelete(perform: delete)
            } header: {
                HStack {
                    Text("Scene")
                    Spacer()
                    NavigationLink {
                        LightStoreSceneView(group: group, selectedScene: $store.selectedScene)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .navigationTitle(group.name)
        .toolbar {
            NavigationLink { 
                AddGroupView(isDone: $isDone, group: group)
                    .navigationTitle("Add Group")
                    .toolbar {
                        Button("Done") {
                            isDone = true
                        }
                    }
            } label: {
                Image(systemName: "pencil.line")
            }
        }
        .onAppear {
            store.updateScene(group: group)
            messageManager.delegate = self
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            let models = meshNetwork.models(subscribedTo: group)
            let arr = models.filter({ $0.parentElement!.parentNode!.usefulModels.contains($0)})
                .compactMap { $0.parentElement?.parentNode }
            nodes = Set(arr)
        }
    }
    
    func subscribe(nodes: Set<Node>) {
        nodes.forEach { node in
            node.usefulModels.forEach { model in
                if !model.isSubscribed(to: group) {
                    messageManager.add {
                        let message: AcknowledgedConfigMessage = ConfigModelSubscriptionAdd(group: group, to: model) ?? ConfigModelSubscriptionVirtualAddressAdd(group: group, to: model)!
                        return try MeshNetworkManager.instance.send(message, to: node)
                    }
                }
            }
        }
    }
    
    func unsubscribe(nodes: Set<Node>) {
        nodes.forEach { node in
            node.usefulModels.forEach { model in
                if model.isSubscribed(to: group) {
                    messageManager.add {
                        let message: AcknowledgedConfigMessage =
                        ConfigModelSubscriptionDelete(group: group, from: model) ??
                        ConfigModelSubscriptionVirtualAddressDelete(group: group, from: model)!
                        return try MeshNetworkManager.instance.send(message, to: node)
                    }
                }
            }
        }
    }
    
    func glLevelsSet() {
        let levels = [UInt8(store.level0), UInt8(store.level1), UInt8(store.level2), UInt8(store.level3)]
        let message = GLLevelMessage(levels: levels)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func runtimeSet() {
        let message = GLRunTimeMessage(time: Int(store.runTime))
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func fadetimeSet() {
        let message = GLFadeTimeMessage(time: Int(store.fadeTime))
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func sceneSet(_ scene: nRFMeshProvision.Scene) {
        let message = SceneRecall(scene.number)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func delete(indexSet: IndexSet) {
        guard let index = indexSet.min() else {
            return
        }
        let scene = store.scenes[index]
        store.scenes.remove(atOffsets: indexSet)
        let message = SceneDelete(scene.number)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
}

extension GroupElementManagerView: MeshMessageDelegate {
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        switch message {
        case let status as GenericLevelStatus:
            print(status)
        case let status as GLColorTemperatureStatus:
            print(status)
        case let status as GLAngleStatus:
            print(status)
        case let status as GLAiStatus:
            print(status)
        case let status as GLSensorStatus:
            print(status)
        case let status as SceneStatus:
            store.selectedScene = status.scene
        case let status as SceneRegisterStatus:
            print(status)
//            MeshNetworkManager.instance.saveModel()
//            dismiss.callAsFunction()
        default: break
        }
    }
}
