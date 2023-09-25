//
//  LightSelectedView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/24.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct LightSelectedView: View {
    @State var editMode: EditMode = .active
    @State var multiSelected: Set<Node> = []
    var nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner }
    var body: some View {
        List(nodes, id: \.self, selection: $multiSelected) { node in
            HStack {
                Image(systemName: multiSelected.contains(node) ? "checkmark.circle" : "circle")
                    .tint(.accentColor)
                Text(node.name ?? "Unknow")
            }
        }
        .navigationTitle("Select Lights")
        .toolbar {
            EditButton()
                .onTapGesture {
                    
                }
        }
        .environment(\.editMode, $editMode)
    }
}

extension Node: Identifiable, Hashable {
    public var id: UUID { UUID() }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(primaryUnicastAddress)
    }
}

#Preview {
    LightSelectedView()
}
