//
//  SceneLightsView.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/10.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct SceneLightsView: View {
    var scene: nRFMeshProvision.Scene
    @State private var addDone: Bool = false
    @State var nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner }
    var body: some View {
        List {
            ForEach(nodes, id: \.primaryUnicastAddress.hex) { node in
                NavigationLink(destination: SceneLightDetailView(node: node, scene: scene)) {
                    ItemView(resource: .meshIcon, title: node.name ?? "Unknow", detail: "Address: 0x\(node.primaryUnicastAddress.hex)")
                }
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Scene Lights")
        .toolbar {
            NavigationLink {
                AddSceneView(isDone: $addDone, scene: scene)
                    .navigationTitle("Add Scene")
                    .toolbar {
                        Button("Done") {
                            addDone = true
                        }
                    }
            } label: {
                Image(systemName: "highlighter")
            }
            NavigationLink {
                LightSelectedView()
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    func delete(indexSet: IndexSet) {
        guard let index = indexSet.min() else {
            return
        }
        let node = nodes[index]
        nodes.remove(atOffsets: indexSet)
        
    }
}
