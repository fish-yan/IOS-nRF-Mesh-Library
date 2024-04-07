//
//  ImportView.swift
//  nRF Mesh
//
//  Created by yan on 2024/3/11.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct ImportView: UIViewControllerRepresentable {
    private var delegate = ImportViewDelegate()
    var importCompletion: (() -> Void)?
    
    init(importCompletion: ( () -> Void)? = nil) {
        self.importCompletion = importCompletion
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(documentTypes: ["public.data", "public.content"], in: .import)
        delegate.importCompletion = {
            print("bbbb")
            importCompletion?()
        }
        picker.delegate = delegate
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIDocumentPickerViewController
    
}

class ImportViewDelegate: NSObject, UIDocumentPickerDelegate {
    
    var importCompletion: (() -> Void)?
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            importWith(fileUrl: url)
        }
    }
    
    private func importWith(fileUrl: URL) {
        //            guard fileUrl.startAccessingSecurityScopedResource() else { // Notice this line right here
        //                 return
        //            }
        do {
            let data = try Data(contentsOf: fileUrl)
            let somejson = try JSONSerialization.jsonObject(with: data)
            guard let json = somejson as? [String: Any] else {
                return
            }
            var isImport = false
            if let meshJson = json["meshData"] {
                isImport = true
                let meshData = try JSONSerialization.data(withJSONObject: meshJson)
                _ = try MeshNetworkManager.instance.import(from: meshData)
            }
            if let glJson = json["glData"] {
                isImport = true
                let glData = try JSONSerialization.data(withJSONObject: glJson)
                _ = try MeshNetworkManager.instance.importGLModel(from: glData)
            }
            if let sequence = json["sequence"] as? UInt32 {
                if let element = MeshNetworkManager.instance.meshNetwork?.localProvisioner?.node?.primaryElement {
                    MeshNetworkManager.instance.setSequenceNumber(sequence + 10, forLocalElement: element)
                }
            }
            if !isImport {
                isImport = true
                _ = try MeshNetworkManager.instance.import(from: data)
            }
            
//            setNewProvisioner()
            MeshNetworkManager.instance.saveAll()
            MeshNetworkManager.instance.loadAll()
            connect()
            importCompletion?()
            //                importSuccess = true
        } catch {
            print(error)
        }
    }
    
    private func setNewProvisioner() {
        let manager = MeshNetworkManager.instance
        let meshNetwork = MeshNetworkManager.instance.meshNetwork!
        let nextAddressRange = meshNetwork.nextAvailableUnicastAddressRange(ofSize: 0x199A)
        let nextGroupRange = meshNetwork.nextAvailableGroupAddressRange(ofSize: 0x0C9A)
        let nextSceneRange = meshNetwork.nextAvailableSceneRange(ofSize: 0x3334)
        let provisioner = Provisioner(name: UIDevice.current.name,
                                  allocatedUnicastRange: [nextAddressRange ?? AddressRange.allUnicastAddresses],
                                  allocatedGroupRange: [nextGroupRange ?? AddressRange.allGroupAddresses],
                                  allocatedSceneRange: [nextSceneRange ?? SceneRange.allScenes])
        let count = max(1, UInt8(manager.localElements.count))
        let next = manager.meshNetwork?.nextAvailableUnicastAddress(for: count, elementsUsing: provisioner) ?? 0001
        try? meshNetwork.add(provisioner: provisioner, withAddress: next)
        try? meshNetwork.setLocalProvisioner(provisioner)
    }
    
    func connect() {
        let manager = MeshNetworkManager.instance
        if manager.proxyFilter.type == .acceptList,
           let provisioner = manager.meshNetwork?.localProvisioner {
            manager.proxyFilter.reset()
            manager.proxyFilter.setup(for: provisioner)
        }
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.meshNetworkDidChange()
    }
    
}
