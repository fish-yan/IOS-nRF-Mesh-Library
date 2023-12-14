//
//  UserSettingsView.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/11.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var selectionRole: UserRole = UserRole(rawValue: GlobalConfig.userRole) ?? .normal
    @State var l0Text: String = String(format: "%.f", GlobalConfig.level0)
    @State var l1Text: String = String(format: "%.f", GlobalConfig.level1)
    @State var l2Text: String = String(format: "%.f", GlobalConfig.level2)
    @State var l3Text: String = String(format: "%.f", GlobalConfig.level3)
    
    @State var onDelayTime: String = String(format: "%d", GlobalConfig.onDelay)
    @State var offDelayTime: String = String(format: "%d", GlobalConfig.offDelay)
    @State var onTransitionTime: String = String(format: "%d", GlobalConfig.onTransition)
    @State var offTransitionTime: String = String(format: "%d", GlobalConfig.offTransition)
    
    @State var isPresented = false
    @State var isNetworkResetPresented = false
    
    @State var isErrorPresented = false
    @State var errorMessage = "Error"
    
    @State var prepareRole: UserRole = .normal
    
    @State var code: String = ""
    
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
                }
                if selectionRole == .commissioner {
                    Section {
                        NavigationLink("Scenes", destination: ScenesManagerView())
                    }
                    
                    Section {
                        Button("Reset") { isNetworkResetPresented = true }
                            .tint(Color.red)
                    }
                }
            }
            .navigationTitle("User Settings")
            .onAppear(perform: onAppear)
            .textFieldAlert(isPresented: $isPresented, title: "Please enter code", text: "", placeholder: "enter code", isSecured: true, action: { text in
                if let text {
                    checkCode(text)
                }
            })
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
        }
    }
}

private extension SettingsView {
    func onAppear() {
        selectionRole = UserRole(rawValue: GlobalConfig.userRole) ?? .normal
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
