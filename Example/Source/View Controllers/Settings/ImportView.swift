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
                    MeshNetworkManager.instance.setSequenceNumber(sequence, forLocalElement: element)
                }
            }
            if !isImport {
                isImport = true
                _ = try MeshNetworkManager.instance.import(from: data)
            }
            MeshNetworkManager.instance.saveAll()
            importCompletion?()
            //                importSuccess = true
        } catch {
            print(error)
        }
    }
}
