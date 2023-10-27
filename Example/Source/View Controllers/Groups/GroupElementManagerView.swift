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
    
    @State var elementMap: [ElementType: [Model]] = [:]
    
    @State var isDone = false
    var body: some View {
        List(ElementType.allCases, id: \.self) { type in
            let arr = elementMap[type]?.compactMap { $0.parentElement?.parentNode } ?? []
            let nodes = Set(arr)
            ElementView(type: type, nodes: nodes, group: group)
        }
        .navigationTitle(group.name)
        .toolbar {
            NavigationLink { 
                AddGroupView(isDone: $isDone, group: group)
                    .navigationTitle("Edit Group")
            } label: {
                Image(systemName: "pencil.line")
            }
        }
        .onAppear(perform: onAppear)
    }
}

extension GroupElementManagerView {
    func onAppear() {
        guard let meshNetwork = MeshNetworkManager.instance.meshNetwork else {
            return
        }
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

struct ElementView: View {
    @State private var isActive: Bool = false
    var type: ElementType
    @State var nodes: Set<Node>
    var group: nRFMeshProvision.Group
    
    var body: some View {
        NavigationLink(isActive: $isActive) {
            LightSelectedView(multiSelected: nodes) { multiSelected in
                nodes = multiSelected
                subscribed()
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
    
    func subscribed() {
        nodes.forEach { node in
            if let model = node.primaryElement?.model(withSigModelId: type.modelId),
               !model.isSubscribed(to: group) {
                let message: AcknowledgedConfigMessage = ConfigModelSubscriptionAdd(group: group, to: model) ?? ConfigModelSubscriptionVirtualAddressAdd(group: group, to: model)!
                _ = try? MeshNetworkManager.instance.send(message, to: node)
            }
        }
    }
}
 
enum ElementType: UInt16, CaseIterable {
    case onOff, level, cct, angle
    
    var image: String {
        switch self {
        case .onOff: "power.circle.fill"
        case .level: "sun.max.fill"
        case .cct: "lightbulb.led.fill"
        case .angle: "light.overhead.right.fill"
        }
    }
    var title: String {
        switch self {
        case .onOff: "On/Off"
        case .level: "Level"
        case .cct: "CCT"
        case .angle: "Beam Angle"
        }
    }
    
    var color: Color {
        switch self {
        case .onOff: .orange
        case .level: .blue
        case .cct: .yellow
        case .angle: .gray
        }
    }
    
    var modelId: UInt16 {
        switch self {
        case .onOff: .genericOnOffServerModelId
        case .level: .genericLevelServerModelId
        case .cct: .JLServerModelId
        case .angle: .JLServerModelId
        }
    }
    
    init?(rawValue: UInt16) {
        switch rawValue {
        case .genericOnOffServerModelId: self = .onOff
        case .genericLevelServerModelId: self = .level
        case .genericLevelServerModelId: self = .cct
        case .genericLevelServerModelId: self = .angle
        default: return nil
        }
    }
}
