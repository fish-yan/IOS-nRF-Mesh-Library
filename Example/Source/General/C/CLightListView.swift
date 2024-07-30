//
//  CLightListView.swift
//  test
//
//  Created by yan on 2024/3/30.
//

import SwiftUI
import NordicMesh

struct CLightListView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var appManager: AppManager
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
        NavigationStack(path: $appManager.c.path) {
            VStack(alignment: .leading) {
                Text("Lights")
                    .font(.title)
                    .foregroundStyle(Color.accent)
                    .padding(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 15))
                    .background(Color.tertiaryBackground, ignoresSafeAreaEdges: .all)
                    .clipShape(.rect(bottomTrailingRadius: 16, topTrailingRadius: 16))
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
                                 Text(": 0x\(String(zone.number, radix: 16))\(coordinate)"))
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
            .background(Color.groupedBackground)
            .onAppear(perform: onAppera)
            .navigationDestination(for: NavPath.self) { target in
                switch target {
                case .cLightView(let node):
                    CLightView(node: node)
                default: Text("")
                }
            }
        }
    }
}

private extension CLightListView {
    func onAppera() {
        nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner && $0.productType?.isLight == true }
//        selectedNode = nodes.first
    }
}

#Preview {
    CLightListView()
}
