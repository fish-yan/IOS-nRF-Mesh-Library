//
//  CLightListView.swift
//  test
//
//  Created by yan on 2024/3/30.
//

import SwiftUI
import NordicMesh

struct BLightListView: View {
    
    @State var nodes: [Node] = []
    @State private var isShowSetting = false
    @State var selectedNode: Node?
    var body: some View {
        List(nodes, id: \.self, selection: $selectedNode) { node in
            NavigationLink(value: NavPath.cLightView(node: node)) {
                VStack(alignment: .leading, spacing: 13) {
                    Text(node.name ?? "Unknow")
                        .font(.labelTitle)
                        .foregroundStyle(Color.accent)
                    Text("Address: 0x\(node.primaryUnicastAddress.hex)")
                        .font(.secondaryLabel)
                        .foregroundColor(Color.secondaryLabel)
                }
            }
            .listRowSeparator(.hidden)
            .listSectionSpacing(0)
            .listRowBackground(
                Color.tertiaryBackground
            )
        }
        .listRowSpacing(10)
        .contentMargins(.top, 10)
        .onAppear(perform: onAppera)
    }
}

private extension BLightListView {
    func onAppera() {
        nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner }
        //        selectedNode = nodes.first
    }
}

#Preview {
    BLightListView()
}
