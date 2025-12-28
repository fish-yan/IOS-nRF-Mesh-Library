//
//  ProScannerView.swift
//  nRF Mesh
//
//  Created by yan on 2025-12-27.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct ProScannerView: UIViewControllerRepresentable {
    private let group: ProGroup?
    private var provider: ProScannerViewProvider!
    init(group: ProGroup?, callback: @escaping (NordicMesh.Node) -> Void) {
        self.group = group
        provider = ProScannerViewProvider(callback: callback)
    }
    func makeUIViewController(context: Context) -> UIViewController {
        let sb = UIStoryboard(name: "Network", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ScannerTableViewController") as! ScannerTableViewController
        vc.proGroup = group
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // 更新逻辑
    }
}

class ProScannerViewProvider: ProvisioningViewDelegate {
    let callback: (NordicMesh.Node) -> Void
    init(callback: @escaping (NordicMesh.Node) -> Void) {
        self.callback = callback
    }
    func provisionerDidProvisionNewDevice(_ node: NordicMesh.Node, whichReplaced previousNode: NordicMesh.Node?) {
        self.callback(node)
    }
    
}
