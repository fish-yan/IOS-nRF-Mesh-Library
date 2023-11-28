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
    
    init(group: nRFMeshProvision.Group) {
        self.group = group
    }
    
    var body: some View {
        List {
            Section {
                ForEach(ElementType.allCases, id: \.self) { type in
                    elementView(type: type)
                }
            } header: {
                Text("Subscribe Model")
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
        }
    }
    
    func elementView(type: ElementType) -> some View {
        let meshNetwork = MeshNetworkManager.instance.meshNetwork!
        var models = [Model]()
        switch type {
        case .onOff:
            models = meshNetwork.models(subscribedTo: group).filter { $0.modelIdentifier == .genericOnOffServerModelId && $0.isBluetoothSIGAssigned }
        case .level:
            models = meshNetwork.models(subscribedTo: group).filter { $0.modelIdentifier == .genericLevelServerModelId && $0.isBluetoothSIGAssigned }
        case .vendor:
            models = meshNetwork.models(subscribedTo: group).filter { !$0.isBluetoothSIGAssigned }
        }
        let arr = models.compactMap { $0.parentElement?.parentNode }
        let nodes = Set(arr)
        return NavigationLink {
            LightSelectedView(multiSelected: nodes, originSelected: nodes) { changes in
                subscribe(type: type, nodes: changes.add)
                unsubscribe(type: type, nodes: changes.delete)
            }
        } label: {
            HStack {
                Image(systemName: type.image)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(type.color)
                    .cornerRadius(6)
                    .clipped()
                Spacer().frame(width: 16)
                Text(type.title)
            }
        }
    }
    
    func subscribe(type: ElementType, nodes: Set<Node>) {
        
        nodes.forEach { node in
            var model: Model?
            switch type {
            case .onOff:
                model = node.onOffModel
            case .level:
                model = node.levelModel
            case .vendor:
                model = node.vendorModel
            }
            if let model,
               !model.isSubscribed(to: group) {
                let message: AcknowledgedConfigMessage = ConfigModelSubscriptionAdd(group: group, to: model) ?? ConfigModelSubscriptionVirtualAddressAdd(group: group, to: model)!
                _ = try? MeshNetworkManager.instance.send(message, to: node)
            }
        }
    }
    
    func unsubscribe(type: ElementType, nodes: Set<Node>) {
        nodes.forEach { node in
            var model: Model?
            switch type {
            case .onOff:
                model = node.onOffModel
            case .level:
                model = node.levelModel
            case .vendor:
                model = node.vendorModel
            }
            if let model,
               model.isSubscribed(to: group) {
                let message: AcknowledgedConfigMessage =
                    ConfigModelSubscriptionDelete(group: group, from: model) ??
                    ConfigModelSubscriptionVirtualAddressDelete(group: group, from: model)!
                _ = try? MeshNetworkManager.instance.send(message, to: node)
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
 
enum ElementType: UInt16, CaseIterable {
    case onOff, level, vendor
    
    var image: String {
        switch self {
        case .onOff: "power.circle.fill"
        case .level: "sun.max.fill"
        case .vendor: "lightbulb.led.fill"
        }
    }
    var title: String {
        switch self {
        case .onOff: "On/Off"
        case .level: "Level"
        case .vendor: "Vendor"
        }
    }
    
    var color: Color {
        switch self {
        case .onOff: .orange
        case .level: .blue
        case .vendor: .yellow
        }
    }
}
