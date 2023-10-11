//
//  LightsView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct LightsView: View {
    var nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner }
    var body: some View {
        NavigationView {
            List {
                ForEach(nodes, id: \.primaryUnicastAddress.hex) { node in
                    NavigationLink(destination: LightDetailView()) {
                        ItemView(resource: .meshIcon, title: node.name ?? "Unknow", detail: "Address: 0x\(node.primaryUnicastAddress.hex)")
                    }
                }
            }
            .navigationTitle("Lights")
            .toolbar {
                NavigationLink(destination: LightsManagerView()) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
}

#Preview {
    LightsView()
}
