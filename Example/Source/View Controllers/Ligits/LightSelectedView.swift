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
    @Binding var isPushed: Bool
    
    @State private var editMode: EditMode = .active
    @State private var multiSelected: Set<Node> = []
    var nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner }
    
    var body: some View {
        List(nodes, id: \.self, selection: $multiSelected) { node in
            VStack(alignment: .leading) {
                Text(node.name ?? "Unknow")
                    .font(.headline)
                Text("Address: 0x\(node.primaryUnicastAddress.hex)")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
        }
        .navigationTitle("Select Lights")
        .toolbar {
            Button {
                isPushed = false
            } label: {
                Text("Done")
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

