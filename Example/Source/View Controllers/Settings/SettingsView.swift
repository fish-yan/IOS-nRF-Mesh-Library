//
//  UserSettingsView.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/11.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var selectionRole: UserRole = UserRole(rawValue: GlobalConfig.userRole) ?? .normal
    
    @State var isPresented = false
    @State var isNetworkResetPresented = false
    
    @State var isFileImportPresented = false
    @State var isFileExportPresented = false
    
    @State var isAlert = false
    @State var alertMessage = ""
    
    @State var isErrorPresented = false
    @State var errorMessage = "Error"
    
    @State var prepareRole: UserRole = .normal
    
    @State var code: String = ""
    @State var sequence: String = "0"
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(UserRole.allCases, id: \.self) { role in
                        Button {
                            if role == .normal {
                                selectionRole = role
                                save()
                            } else {
                                isPresented = true
                                prepareRole = role
                            }
                            
                        } label: {
                            HStack {
                                Text(role.string.capitalized)
                                    .foregroundStyle(Color(UIColor.label))
                                Spacer()
                                Image(systemName: "checkmark")
                                    .opacity(role == selectionRole ? 1 : 0)
                            }
                        }
                    }
                } header: {
                    Text("Roles")
                }
                if selectionRole == .commissioner {
                    Section {
                        NavigationLink("Scenes", destination: ScenesManagerView())
                    } header: {
                        Text("Scenes")
                    }
                    
                    Section {
                        Button("Export") {
                            isFileExportPresented = true
                        }
                        Button("Import") {
                            isFileImportPresented = true
                        }
                        HStack {
                            Text("Set Sequence")
                            Spacer()
                            TextField("Sequence", text: $sequence)
                                .frame(width: 100)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Save") {
                                let s: UInt32 = UInt32(sequence) ?? 0
                                if let network = MeshNetworkManager.instance.meshNetwork,
                                   let element = network.localProvisioner?.node?.primaryElement {
                                    MeshNetworkManager.instance.setSequenceNumber(s, forLocalElement: element)
                                    alertMessage = "set sequence success"
                                    isAlert = true
                                }
                            }
                            .frame(width: 40)
                        }
//                        .fileImporter(isPresented: $isFileImportPresented, allowedContentTypes: [.json]) { result in
//                            switch result {
//                            case .success(let fileUrl):
//                                importWith(fileUrl: fileUrl)
//                            case .failure(let error):
//                                print(error)
//                            }
//                        }
                    } header: {
                        Text("File")
                    }
                }
                Section {
                    let info = Bundle.main.infoDictionary ?? [:]
                    let name = info["CFBundleDisplayName"] as? String
                    let version = info["CFBundleShortVersionString"] as? String
                    let build = info["CFBundleVersion"] as? String
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text(name ?? "")
                    }
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("\(version ?? "")(\(build ?? ""))")
                    }
                } header: {
                    Text("App Info")
                }
                if selectionRole == .commissioner {
                    Section {
                        Button("Reset") { isNetworkResetPresented = true }
                            .tint(Color.red)
                    } header: {
                        Text("Reset")
                    }
                }
                Section {
                    Button("Back to the new UI") {
                        dismiss.callAsFunction()
                    }
                }
            }
            .navigationTitle("User Settings")
            .onAppear(perform: onAppear)
            .alert("Please enter code", isPresented: $isPresented, actions: {
                SecureField("enter code", text: $code)
                    
                Button("Cancel", role: .cancel){}
                Button("OK") {
                    checkCode(code)
                }
            })
//            .textFieldAlert(isPresented: $isPresented, title: "Please enter code", text: "", placeholder: "enter code", isSecured: true, action: { text in
//                if let text {
//                    checkCode(text)
//                }
//            })
            .alert("Error", isPresented: $isErrorPresented) {
                Button("OK", role: .cancel){}
            } message: {
                Text(errorMessage)
            }
            .alert("Reset Network", isPresented: $isNetworkResetPresented) {
                Button("Reset", role: .destructive, action: reset)
            } message: {
                Text("Resetting the network will erase all network data.\nMake sure you exported it first.")
            }
            .alert(alertMessage, isPresented: $isAlert) {
                Button("OK", role: .cancel){}
            }
            .sheet(isPresented: $isFileExportPresented) {
                ExportView()
            }
            .sheet(isPresented: $isFileImportPresented) {
                ImportView {
                    alertMessage = "Import success"
                    isAlert = true
                    onAppear()
                }
            }
            .scrollDismissesKeyboard(.automatic)
        }
    }
    
    private func importWith(fileUrl: URL) {
        if #available(iOS 17.0, *) {
            guard fileUrl.startAccessingSecurityScopedResource() else { // Notice this line right here
                return
            }
        }
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
            if !isImport {
                isImport = true
                _ = try MeshNetworkManager.instance.import(from: data)
            }
            MeshNetworkManager.instance.saveAll()
            alertMessage = "Import success"
            isAlert = true
        } catch {
            print(error)
        }
    }
}

private extension SettingsView {
    func onAppear() {
        selectionRole = UserRole(rawValue: GlobalConfig.userRole) ?? .normal
        if let network = MeshNetworkManager.instance.meshNetwork,
           let element = network.localProvisioner?.node?.primaryElement {
            let s = MeshNetworkManager.instance.getSequenceNumber(ofLocalElement: element) ?? 0
            sequence = "\(s)"
        }
    }
    
    func checkCode(_ code: String) {
        if prepareRole == .supervisor {
            if code == "666666" {
                selectionRole = prepareRole
                save()
            } else {
                errorMessage = "Code is error"
                isErrorPresented = true
            }
        }
        if prepareRole == .commissioner {
            if code == "888888" {
                selectionRole = prepareRole
                save()
            } else {
                errorMessage = "Code is error"
                isErrorPresented = true
            }
        }
    }
    
    func save() {
        GlobalConfig.userRole = selectionRole.rawValue
    }
    
    func reset() {
        _ = MeshNetworkManager.instance.clearAll()
        (UIApplication.shared.delegate as! AppDelegate).createNewMeshNetwork()
    }
    
    func createNetwork(withFixedKeys fixed: Bool,
                       networkKeys: Int, applicationKeys: Int,
                       groups: Int, virtualGroups: Int, scenes: Int) {
        let network = (UIApplication.shared.delegate as! AppDelegate).createNewMeshNetwork()
        
        var index: UInt8 = 1
        // In debug mode, with fixed keys, the primary network key added by default has to be
        // removed and replaced with a one with fixed value.
        if fixed {
            try? network.remove(networkKeyWithKeyIndex: 0, force: true)
            let key = Data(repeating: 0, count: 15) + index
            index += 1
            _ = try? network.add(networkKey: key, name: "Primary Network Key")
        }
        // Add random or fixed key Network and Application Keys.
        for i in 1..<networkKeys {
            guard index < UInt8.max else { break }
            let key = fixed ? Data(repeating: 0, count: 15) + index : Data.random128BitKey()
            index += 1
            _ = try? network.add(networkKey: key, name: "Network Key \(i + 1)")
        }
        for i in 0..<applicationKeys {
            guard index < UInt8.max else { break }
            let key = fixed ? Data(repeating: 0, count: 15) + index : Data.random128BitKey()
            index += 1
            _ = try? network.add(applicationKey: key, name: "Application Key \(i + 1)")
        }
        // Add groups and scenes.
        for _ in 0..<groups {
            if let address = network.nextAvailableGroupAddress() {
                _ = try? network.add(group: Group(name: String(address, radix: 16, uppercase: true), address: address))
            }
        }
        for i in 0..<virtualGroups {
            _ = try? network.add(group: Group(name: "Virtual Group \(i + 1)", address: MeshAddress(UUID())))
        }
        for i in 0..<scenes {
            if let sceneNumber = network.nextAvailableScene() {
                _ = try? network.add(scene: sceneNumber, name: "Scene \(i + 1)")
            }
        }
        
        if MeshNetworkManager.instance.save() {
            //            reload()
            //            resetViews()
        } else {
            errorMessage = "Mesh configuration could not be saved."
            isErrorPresented = true
        }
    }
}

struct UserSettingsItem: View {
    var title: String
    @Binding var text: String
    var unit: String
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
                .frame(width: 50)
                .keyboardType(.numberPad)
            Text(unit)
        }
    }
}

struct TextFile: FileDocument {
    // 告诉系统我们仅支持纯文本
    static var readableContentTypes: [UTType] = [.json]

    // 默认情况下，您的文档为空
    var text = ""

    // 创建新的空文档的简单初始化程序
    init(initialText: String = "") {
        text = initialText
    }

    // 此初始化程序加载以前保存的数据
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    // 当系统要将数据写入磁盘时，将调用此方法
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
