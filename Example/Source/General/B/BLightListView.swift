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
    @State private var searchText = ""
    
    var filterNodes: [Node] {
        if searchText.isEmpty {
            nodes
        } else {
            nodes.filter({(($0.name ?? "").lowercased().contains(searchText.lowercased()) == true) || $0.primaryUnicastAddress == UInt16(searchText, radix: 16)})
        }
    }
    var body: some View {
        VStack {
            SearchBar(text: $searchText, prompt: Localized("Name") + "," + Localized("Unicast Address"))
            List(filterNodes, id: \.self, selection: $selectedNode) { node in
                NavigationLink(value: NavPath.cLightView(node: node)) {
                    VStack(alignment: .leading, spacing: 13) {
                        Text(node.name ?? "Unknow")
                            .font(.labelTitle)
                            .foregroundStyle(Color.accent)
                        (Text("Address") +
                         Text(": 0x\(node.primaryUnicastAddress.hex)"))
                        .font(.secondaryLabel)
                        .foregroundColor(Color.secondaryLabel)
                        if let coordinate = node.coordinate {
                            let zone = GLMeshNetworkModel.instance.zone(node: node)
                            (Text("Position") +
                             Text(": 0x\(String(zone.number, radix: 16))\(coordinate.replacingOccurrences(of: "Unknown", with: ""))"))
                            .font(.secondaryLabel)
                            .foregroundColor(Color.secondaryLabel)
                        }
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
        }
        .onAppear(perform: onAppera)
    }
}

private extension BLightListView {
    func onAppera() {
        nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner && $0.isLight }
        //        selectedNode = nodes.first
    }
}

#Preview {
    BLightListView()
}
