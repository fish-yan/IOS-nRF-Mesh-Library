//
//  GroupElementManagerView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/24.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

class GroupElementViewModel: ObservableObject {
    @Published var level0: Double = 100
    @Published var level1: Double = 70
    @Published var level2: Double = 50
    @Published var level3: Double = 20
    @Published var runTime: Double = 300
    @Published var fadeTime: Double = 60
    
    @Published var elementMap: [ElementType: [Model]] = [:]
    
    @Published var scenes: [nRFMeshProvision.Scene] = []
    
    func updateModels(with group: nRFMeshProvision.Group) {
        guard let meshNetwork = MeshNetworkManager.instance.meshNetwork else {
            return
        }
        elementMap.removeAll()
        meshNetwork.models(subscribedTo: group).forEach({ model in
            if let type = ElementType(rawValue: model.modelIdentifier) {
                if var models = elementMap[type] {
                    models.append(model)
                    elementMap[type] = models
                } else {
                    let models = [model]
                    elementMap[type] = models
                }
            }
        })
    }
    
    func updateScene() {
        guard let meshNetwork = MeshNetworkManager.instance.meshNetwork else {
            return
        }
        scenes = meshNetwork.scenes
    }
}

struct GroupElementManagerView: View {
    var group: nRFMeshProvision.Group
    
    @ObservedObject var viewModel = GroupElementViewModel()
    
    @State var isDone = false
    
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
                SliderView("L0", value: $viewModel.level0)
                SliderView("L1", value: $viewModel.level1)
                SliderView("L2", value: $viewModel.level2)
                SliderView("L3", value: $viewModel.level3)
                HStack {
                    Spacer()
                    Button("send", action: glLevelsSet)
                }
            } header: {
                Text("General Luminaire Level")
            }
            
            Section {
                SliderView("run time", value: $viewModel.runTime, in: 0...900, unit: "s", onDragEnd: runtimeSet)
                SliderView("fade time", value: $viewModel.fadeTime, in: 0...60, unit: "s", onDragEnd: fadetimeSet)
            }
            Section {
                ForEach(viewModel.scenes, id: \.number) { scene in
                    NavigationLink {
                        SceneGroupDetailView(group: group, scene: scene)
                    } label: {
                        ItemView(resource: .icScenes24Pt, title: scene.name, detail: "Number: \(scene.number)")
                    }

                }
            } header: {
                Text("Scene")
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
            viewModel.updateModels(with: group)
            viewModel.updateScene()
        }
    }
    
    func elementView(type: ElementType) -> some View {
        let models = viewModel.elementMap[type] ?? []
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
            if let model = node.primaryElement?.model(withSigModelId: type.modelId),
               !model.isSubscribed(to: group) {
                let message: AcknowledgedConfigMessage = ConfigModelSubscriptionAdd(group: group, to: model) ?? ConfigModelSubscriptionVirtualAddressAdd(group: group, to: model)!
                _ = try? MeshNetworkManager.instance.send(message, to: node)
            }
        }
        viewModel.updateModels(with: group)
    }
    
    func unsubscribe(type: ElementType, nodes: Set<Node>) {
        nodes.forEach { node in
            if let model = node.primaryElement?.model(withSigModelId: type.modelId),
               model.isSubscribed(to: group) {
                let message: AcknowledgedConfigMessage =
                    ConfigModelSubscriptionDelete(group: group, from: model) ??
                    ConfigModelSubscriptionVirtualAddressDelete(group: group, from: model)!
                _ = try? MeshNetworkManager.instance.send(message, to: node)
            }
        }
        viewModel.updateModels(with: group)
    }
    
    func glLevelsSet() {
        let levels = [UInt8(viewModel.level0), UInt8(viewModel.level1), UInt8(viewModel.level2), UInt8(viewModel.level3)]
        let message = GLLevelMessage(levels: levels)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func runtimeSet() {
        let message = GLRunTimeMessage(time: Int(viewModel.runTime))
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func fadetimeSet() {
        let message = GLFadeTimeMessage(time: Int(viewModel.fadeTime))
        _ = try? MeshNetworkManager.instance.send(message, to: group)
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
    
    var modelId: UInt16 {
        switch self {
        case .onOff: .genericOnOffServerModelId
        case .level: .genericLevelServerModelId
        case .vendor: .glServerModelId
        }
    }
    
    init?(rawValue: UInt16) {
        switch rawValue {
        case .genericOnOffServerModelId: self = .onOff
        case .genericLevelServerModelId: self = .level
        case .glServerModelId: self = .vendor
        default: return nil
        }
    }
}
