//
//  UserSettingsView.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/11.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct UserSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var selectionRole: UserRole = GlobalConfig.userRole
    @State var l0Text: String = String(format: "%.f", GlobalConfig.level0)
    @State var l1Text: String = String(format: "%.f", GlobalConfig.level1)
    @State var l2Text: String = String(format: "%.f", GlobalConfig.level2)
    @State var l3Text: String = String(format: "%.f", GlobalConfig.level3)
    
    @State var onDelayTime: String = String(format: "%d", LocalStorage.onDelay)
    @State var offDelayTime: String = String(format: "%d", LocalStorage.offDelay)
    @State var onTransitionTime: String = String(format: "%d", LocalStorage.onTransitionSteps)
    @State var offTransitionTime: String = String(format: "%d", LocalStorage.offTransitionSteps)
    
    @State var isPresented = false
    @State var isNetworkResetPresented = false
    
    @State var isErrorPresented = false
    @State var errorMessage = "Error"
    
    @State var prepareRole: UserRole = .normal
        
    @State var code: String = ""
            
    var body: some View {
        List {
            Section {
                ForEach(UserRole.allCases, id: \.self) { role in
                    Button {
                        if role == .normal {
                            selectionRole = role
                        } else {
                            isPresented = true
                            prepareRole = role
                        }
                        
                    } label: {
                        HStack {
                            Text(role.rawValue.capitalized)
                                .foregroundStyle(Color(UIColor.label))
                            Spacer()
                            Image(systemName: "checkmark")
                                .opacity(role == selectionRole ? 1 : 0)
                        }
                    }
                }
            }
            if selectionRole == .supervisor || selectionRole == .commissioner {
                Section {
                    UserSettingsItem(title: "L0", text: $l0Text, unit: "%")
                    UserSettingsItem(title: "L1", text: $l1Text, unit: "%")
                    UserSettingsItem(title: "L2", text: $l2Text, unit: "%")
                    UserSettingsItem(title: "L3", text: $l3Text, unit: "%")
                } header: {
                    Text("Level")
                }
                
                Section {
                    UserSettingsItem(title: "On Delay Time", text: $onDelayTime, unit: "s")
                    UserSettingsItem(title: "Off Delay Time", text: $offDelayTime, unit: "s")
                    UserSettingsItem(title: "On Transaction Time", text: $onTransitionTime, unit: "s")
                    UserSettingsItem(title: "Off Transaction Time", text: $offTransitionTime, unit: "s")
                } header: {
                    Text("Time")
                }
            }
            
            if selectionRole == .commissioner {
                Section {
                    Button("Reset") { isNetworkResetPresented = true }
                        .tint(Color.red)
                }
            }
        }
        .navigationTitle("User Settings")
        .toolbar {
            Button("Save", action: save)
        }
        .onAppear(perform: onAppear)
        .alert("Please enter code", isPresented: $isPresented) {
            SecureField("enter code", text: $code)
            Button("OK", action: checkCode)
            Button("Cancel", role: .cancel){}
        }
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

private extension UserSettingsView {
    func onAppear() {
        selectionRole = GlobalConfig.userRole
        
        l0Text = String(format: "%.f", GlobalConfig.level0)
        l1Text = String(format: "%.f", GlobalConfig.level1)
        l2Text = String(format: "%.f", GlobalConfig.level2)
        l3Text = String(format: "%.f", GlobalConfig.level3)
        
        onDelayTime = String(format: "%d", LocalStorage.onDelay)
        offDelayTime = String(format: "%d", LocalStorage.offDelay)
        onTransitionTime = String(format: "%d", LocalStorage.onTransitionSteps)
        offTransitionTime = String(format: "%d", LocalStorage.offTransitionSteps)
    }
    
    func checkCode() {
        if prepareRole == .supervisor {
            if code == "666666" {
                selectionRole = prepareRole
            } else {
                errorMessage = "Code is error"
                isErrorPresented = true
            }
        }
        if prepareRole == .commissioner {
            if code == "888888" {
                selectionRole = prepareRole
            } else {
                errorMessage = "Code is error"
                isErrorPresented = true
            }
        }
        code = ""
    }
    
    func save() {
        LocalStorage.userRole = selectionRole.rawValue
        LocalStorage.level0 = Double(l0Text) ?? 0
        LocalStorage.level1 = Double(l1Text) ?? 0
        LocalStorage.level2 = Double(l2Text) ?? 0
        LocalStorage.level3 = Double(l3Text) ?? 0
        LocalStorage.onDelay = UInt8(onDelayTime) ?? 0
        LocalStorage.offDelay = UInt8(offDelayTime) ?? 0
        LocalStorage.onTransitionSteps = UInt8(onTransitionTime) ?? 0
        LocalStorage.offTransitionSteps = UInt8(offTransitionTime) ?? 0
        dismiss.callAsFunction()
    }
    
    func reset() {
        _ = MeshNetworkManager.instance.clear()
        createNetwork(withFixedKeys: false,
            networkKeys: 1,
            applicationKeys: 1,
            groups: 6,
            virtualGroups: 0,
            scenes: 0)
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
        for i in 0..<groups {
            if let address = network.nextAvailableGroupAddress() {
                _ = try? network.add(group: Group(name: "Group \(i + 1)", address: address))
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

#Preview {
    UserSettingsView()
}
