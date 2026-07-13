//
//  ProLightSearchListView.swift
//  nRF Mesh
//
//  Created by yan on 2026-01-05.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct ProLightListSearchView: View {
    @State var nodes: [Node] = []
    @State private var searchText = ""
    @State private var height: CGFloat = 0
    let group: ProGroup
    @Binding var isPresented: Bool
    @Binding var selectedNode: Node
    var filterNodes: [Node] {
        if searchText.isEmpty {
            nodes
        } else {
            nodes.filter({(($0.name ?? "").lowercased().contains(searchText.lowercased()) == true) || $0.primaryUnicastAddress == UInt16(searchText, radix: 16)})
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filterNodes, id: \.self) { node in
                Button {
                    selectedNode = node
                    isPresented = false
                } label: {
                    HStack {
                        Text(node.name ?? "Unknown")
                        Spacer()
                        if selectedNode == node {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Name, Unicast Address")
            .navigationTitle("List")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            onAppera()
        }
        .frame(width: 300, height: height)
    }
}

private extension ProLightListSearchView {
    func onAppera() {
        nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter {
            !$0.isProvisioner && $0.isLight && $0.name?.hasPrefix(group.prefix) == true
        }
        height = min(200 + CGFloat(nodes.count) * 44, 650)
    }
}

