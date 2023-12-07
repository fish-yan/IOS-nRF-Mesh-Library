//
//  LightsManagerView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/22.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct LightsManagerView: View {
    @State private var add = false
    @State var nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner }
    var body: some View {
        List {
            ForEach(nodes, id: \.primaryUnicastAddress.hex) { node in
                NavigationLink {
                    LightManagerDetailView(node: node)
                } label: {
                    ItemView(resource: .meshIcon, title: node.name ?? "Unknow", detail: "Address: 0x\(node.primaryUnicastAddress.hex)")
                }
            }
        }
        .navigationTitle("Lights Manager")
        .toolbar {
            NavigationLink {
                ScanDeviceView()
                    .navigationTitle("Provision Device")
            } label: {
                Image(systemName: "plus")
            }
            .opacity(GlobalConfig.isShowAdvance ? 1 : 0)
        }
        .onAppear {
            nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner }
        }
    }
}

struct NodeView: UIViewControllerRepresentable {
    var node: Node
    func makeUIViewController(context: Context) -> NodeViewController {
        let storyboard = UIStoryboard(name: "Network", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(identifier: "NodeViewController") as! NodeViewController
        vc.node = node
        return vc
    }
    
    func updateUIViewController(_ uiViewController: NodeViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = NodeViewController
}

struct ScanDeviceView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ScannerTableViewController {
        let storyboard = UIStoryboard(name: "Network", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(identifier: "ScannerTableViewController") as! ScannerTableViewController
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ScannerTableViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = ScannerTableViewController
}
