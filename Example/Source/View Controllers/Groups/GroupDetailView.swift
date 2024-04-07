//
//  LightDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/21.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct GroupDetailView: View {
    
    var group: nRFMeshProvision.Group
    
    @State private var isError: Bool = false
    @State private var errorMessage: String = "Error"
    
    @ObservedObject var store = MessageDetailStore()
    
    private var messageManager = MeshMessageManager()
    
    init(group: nRFMeshProvision.Group) {
        self.group = group
    }
    
    var body: some View {
        List {
            Section {
                Button {
                    onOffSet()
                } label: {
                    Image(systemName: "power.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .tint(store.isOn == true ? .orange : .gray.opacity(0.5))
                        .background(.clear)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            }
            .buttonStyle(.borderless)
            
            Section {
                Toggle("AI", isOn: $store.isAi)
                    .onChange(of: store.isAi) { value in
                        aiSet()
                    }
                Toggle("Sensor", isOn: $store.isSensor)
                    .onChange(of: store.isSensor) { value in
                        sensorSet()
                    }
            }
            Section {
                SliderView("Level", value: $store.level) { isEditing in
                    levelSet()
                }
//                SliderView("CCT", value: $store.CCT) { isEditing in
//                    CCTSet()
//                }
            }
            Section {
                ForEach(store.scenes, id: \.number) { scene in
                    HStack {
                        Text(scene.name)
                        Spacer()
                        Button {
                            sceneSet(scene)
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.headline)
                                .opacity(store.selectedScene == scene.number ? 1 : 0)
                        }
                    }
                }
            }
        }
        .navigationTitle(group.name)
        .alert("Error", isPresented: $isError) { } message: {
            Text(errorMessage)
        }
        .onAppear {
            messageManager.delegate = self
            store.updateScene(group: group)
        }
    }
}

extension GroupDetailView {
    func onAppear() {
        messageManager.delegate = self
        guard MeshNetworkManager.bearer.isConnected else {
            return
        }
    }
    
    func onOffSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        let message = GenericOnOffSet(!store.isOn!)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
        store.isOn?.toggle()
    }
    
    func aiSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        let message = GLAiMessage(status: store.isAi ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
        store.isAi.toggle()
    }
    
    func sensorSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        let message = GLSensorMessage(status: store.isSensor ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
        store.isSensor.toggle()
    }
    
    func levelSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        let level = Int16(min(32767, -32768 + 655.36 * store.level)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func CCTSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        let colorTemperature = UInt8(store.CCT)
        let message = GLColorTemperatureMessage(colorTemperature: colorTemperature)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func sceneSet(_ scene: nRFMeshProvision.Scene) {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        let message = SceneRecall(scene.number)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
}

extension GroupDetailView: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        switch message {
        case let status as GenericOnOffStatus:
            print(status.isOn)
        case let status as GenericLevelStatus:
            print(status.level)
        case let status as GLColorTemperatureStatus:
            print(status)
        case let status as GLAngleStatus:
            print(status)
        case let status as GLAiStatus:
            print(status)
        case let status as GLSensorStatus:
            print(status)
        case let status as SceneStatus:
            store.selectedScene = status.scene
        default: break
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didSendMessage message: MeshMessage, from localElement: Element, to destination: MeshAddress) {
        
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager, failedToSendMessage message: MeshMessage, from localElement: Element, to destination: MeshAddress, error: Error) {
        print(message, error.localizedDescription)
//        store.error = .messageError(error.localizedDescription)
//        store.isError = true
    }
    
}
