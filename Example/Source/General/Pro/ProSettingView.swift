//
//  ProSettingView.swift
//  nRF Mesh
//
//  Created by yan on 2025-12-28.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh
import UniformTypeIdentifiers

struct ProSettingView: View {
    @State private var showingImporter: Bool = false
    @State private var showingExporter: Bool = false
    @State private var presentRestAlert: Bool = false
    @State private var fileUrl: URL?
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("导入") {
                        showingImporter = true
                    }
                    .fileImporter(
                        isPresented: $showingImporter,
                        allowedContentTypes: [.data, .content],
                        allowsMultipleSelection: false) { result in
                            switch result {
                            case .success(let urls):
                                if let url = urls.first {
                                    importFile(url: url)
                                }
                            case .failure(let error):
                                print(error)
                            }
                            
                        }
                    if let fileUrl {
                        ShareLink(item: fileUrl) {
                            Text("导出")
                        }
                    }
                }
                Section {
                    Button("重置网络", role: .destructive) {
                        presentRestAlert = true
                    }
                }
            }
            .navigationTitle("设置")
            .alert("警告", isPresented: $presentRestAlert) {
                Button("取消", role: .cancel) { }
                Button("重置网络", role: .destructive) {
                    _ = MeshNetworkManager.instance.clearAll()
                    ProGroupManager.shared.clearAll()
                    self.openNewNetworkWizard()
                }
            } message: {
                Text("是否重置当前网络？重置后会丢失所有本地数据。请确定是否已经备份数据。")
            }
            .onAppear {
                do {
                    fileUrl = try export()
                } catch {
                    
                }
            }
        }
    }
}

extension ProSettingView {
    func importFile(url: URL) {
        let manager = MeshNetworkManager.instance
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard url.startAccessingSecurityScopedResource() else { // Notice this line right here
                 return
            }
            do {
                let data = try Data(contentsOf: url)
                let somejson = try JSONSerialization.jsonObject(with: data)
                guard let json = somejson as? [String: Any] else {
                    return
                }
                var isImport = false
                var meshNetwork: MeshNetwork?
                if let meshJson = json["meshData"] {
                    isImport = true
                    let meshData = try JSONSerialization.data(withJSONObject: meshJson)
                    meshNetwork = try manager.import(from: meshData)
                }
                if let glJson = json["glData"] {
                    isImport = true
                    let glData = try JSONSerialization.data(withJSONObject: glJson)
                    _ = try manager.importGLModel(from: glData)
                }
                if let sequence = json["sequence"] as? UInt32 {
                    if let element = manager.meshNetwork?.localProvisioner?.node?.primaryElement {
                        manager.setSequenceNumber(sequence + 300, forLocalElement: element)
                    }
                }
                if let proGroupJson = json["proGroups"] {
                    let proGroup = try JSONSerialization.data(withJSONObject: proGroupJson)
                    ProGroupManager.shared.importProGroup(proGroup)
                }
                if !isImport {
                    isImport = true
                    meshNetwork = try manager.import(from: data)
                }
                manager.saveAll()
                manager.loadAll()
                guard meshNetwork != nil else { return }
                // Try restoring the Provisioner used last time on this device.
                self.saveAndReload()
            } catch let DecodingError.dataCorrupted(context) {
                let path = context.codingPath.path
                print("Import failed: \(context.debugDescription) (\(path))")
                DispatchQueue.main.async {
                    showError("Importing Mesh Network configuration failed.\n"
                                              + "\(context.debugDescription)\nPath: \(path).")
                }
            } catch let DecodingError.keyNotFound(key, context) {
                let path = context.codingPath.path
                print("Import failed: Key \(key) not found in \(path)")
                DispatchQueue.main.async {
                    showError("Importing Mesh Network configuration failed.\n"
                                              + "No value associated with key: \(key.stringValue) in: \(path).")
                }
            } catch let DecodingError.valueNotFound(value, context) {
                let path = context.codingPath.path
                print("Import failed: Value of type \(value) required in \(path)")
                DispatchQueue.main.async {
                    showError("Importing Mesh Network configuration failed.\n"
                                              + "No value associated with key: \(path).")
                }
            } catch let DecodingError.typeMismatch(type, context) {
                let path = context.codingPath.path
                print("Import failed: Type mismatch in \(path) (\(type) was required)")
                DispatchQueue.main.async {
                    showError("Importing Mesh Network configuration failed.\n"
                                              + "Type mismatch in: \(path). Expected: \(type).")
                }
            } catch {
                print("Import failed: \(error)")
                DispatchQueue.main.async {
                    showError("Importing Mesh Network configuration failed.\n"
                                              + "Check if the file is valid.")
                }
            }
        }
    }
    
    func saveAndReload() {
        if MeshNetworkManager.instance.save() {
            DispatchQueue.main.async {
                (UIApplication.shared.delegate as! AppDelegate).meshNetworkDidChange()
                self.connect()
                showSuccess("Mesh Network configuration imported.")
            }
        } else {
            showError("Mesh configuration could not be saved.")
        }
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
    
    func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            showSuccess("导出成功")
        case .failure(let error):
            showError("导出失败")
        }
    }
    
    func openNewNetworkWizard() {
        _ = MeshNetworkManager.instance.clearAll()
        (UIApplication.shared.delegate as! AppDelegate).createNewMeshNetwork()
    }
    
    func export() throws -> URL {
        let manager = MeshNetworkManager.instance
        let meshData = manager.export(.full)
        let meshJson = try JSONSerialization.jsonObject(with: meshData)
        
        let glData = manager.exportGLModel()
        let glJson = try JSONSerialization.jsonObject(with: glData)
        var sequence: UInt32 = 0
        if let element = manager.meshNetwork?.localProvisioner?.node?.primaryElement,
           let localSequence = manager.getSequenceNumber(ofLocalElement: element) {
            sequence = localSequence
        }
        
        let proGroup = ProGroupManager.shared.exportProGroup()
        let groupJson = try JSONSerialization.jsonObject(with: proGroup)
        
        let newJson = ["meshData": meshJson, "glData": glJson, "sequence": sequence, "proGroups": groupJson]
        let data = try JSONSerialization.data(withJSONObject: newJson)
        let fileName = "Arcosence Pro.json"
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
        
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }
}

#Preview {
    ProSettingView()
}
