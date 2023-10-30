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
    @Published var elementMap: [ElementType: [Model]] = [:]
    
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
}

struct GroupElementManagerView: View {
    var group: nRFMeshProvision.Group
    
    @ObservedObject var vm = GroupElementViewModel()
    
    @State var isDone = false
    
    var body: some View {
        List(ElementType.allCases, id: \.self) { type in
            elementView(type: type)
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
            vm.updateModels(with: group)
        }
    }
    
    func elementView(type: ElementType) -> some View {
        let models = vm.elementMap[type] ?? []
        let arr = models.compactMap { $0.parentElement?.parentNode }
        var nodes = Set(arr)
        return NavigationLink {
            LightSelectedView(multiSelected: nodes) { changes in
                subscribed(type: type, nodes: changes.add)
                unsubscribed(type: type, nodes: changes.delete)
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
    
    func subscribed(type: ElementType, nodes: Set<Node>) {
        nodes.forEach { node in
            if let model = node.primaryElement?.model(withSigModelId: type.modelId),
               !model.isSubscribed(to: group) {
                let message: AcknowledgedConfigMessage = ConfigModelSubscriptionAdd(group: group, to: model) ?? ConfigModelSubscriptionVirtualAddressAdd(group: group, to: model)!
                _ = try? MeshNetworkManager.instance.send(message, to: node)
            }
        }
        vm.updateModels(with: group)
    }
    
    func unsubscribed(type: ElementType, nodes: Set<Node>) {
        nodes.forEach { node in
            if let model = node.primaryElement?.model(withSigModelId: type.modelId),
               model.isSubscribed(to: group) {
                let message: AcknowledgedConfigMessage =
                    ConfigModelSubscriptionDelete(group: group, from: model) ??
                    ConfigModelSubscriptionVirtualAddressDelete(group: group, from: model)!
                _ = try? MeshNetworkManager.instance.send(message, to: node)
            }
        }
        vm.updateModels(with: group)
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
