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
    @State var nodes: [Node] = []
    @State private var isShowSetting = false
    var body: some View {
        NavigationView {
            List {
                ForEach(nodes, id: \.primaryUnicastAddress.hex) { node in
                    NavigationLink(destination: LightDetailView(node: node)) {
                        ItemView(resource: .meshIcon, title: node.name ?? "Unknow", detail: "Address: 0x\(node.primaryUnicastAddress.hex)")
                    }
                }
            }
            .navigationTitle("Lights")
            .toolbar {
                NavigationLink(destination: LightsManagerView()) {
                    Image(systemName: "gearshape")
                }
                .opacity(isShowSetting ? 1 : 0)
            }
            .onAppear {
                isShowSetting = GlobalConfig.isShowSetting
                nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner }
            }
        }
    }
}

#Preview {
    LightsView()
}
