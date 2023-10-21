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
            ElementView(type: type, models: elementMap[type] ?? [])
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
    var models: [Model]
    private var nodes: Set<Node> {
        let arr = models.compactMap { $0.parentElement?.parentNode }
        return Set(arr)
    }
    var body: some View {
        NavigationLink(destination: LightSelectedView(multiSelected: nodes), isActive: $isActive) {
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
        case .cct: .genericLevelServerModelId
        case .angle: .genericLevelServerModelId
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
