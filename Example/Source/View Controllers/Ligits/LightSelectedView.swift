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
    
    @Environment(\.dismiss) var dismiss
    
    var type: ElementType
    
    @State var multiSelected: Set<Node> = []
    
    @State private var editMode: EditMode = .active
    var allNodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner }
    
    var body: some View {
        List(allNodes, id: \.primaryUnicastAddress, selection: $multiSelected) { node in
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
            Button(action: doneAction) {
                Text("Done")
            }
        }
        .environment(\.editMode, $editMode)
    }
}

extension LightSelectedView {
    func doneAction() {
        
        dismiss.callAsFunction()
    }
}

extension Node: Identifiable, Hashable {
    public var id: UUID { UUID() }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(primaryUnicastAddress)
    }
}

