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
                Section {
                    ForEach(nodes, id: \.primaryUnicastAddress.hex) { node in
                        NavigationLink(destination: LightControlView(node: node)) {
                            ItemView(resource: .meshIcon, title: node.name ?? "Unknow", detail: "Address: 0x\(node.primaryUnicastAddress.hex)")
                        }
                    }
                } footer: {
                    Text("")
                }
            }
            .navigationTitle("Lights")
            .toolbar {
                NavigationLink {
                    ScanDeviceView()
                        .navigationTitle("Provision Device")
                } label: {
                    Image(systemName: "plus")
                }
                .opacity(isShowSetting ? 1 : 0)
            }
            .onAppear {
                isShowSetting = GlobalConfig.isShowAdvance
                nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner }
            }
        }
    }
}
