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
        
    @State private var isOn = false
    @State private var level: Double = 0
    @State private var CCT: Double = 0
    @State private var angle: Double = 0
    @State private var directions: CGPoint = .zero
    
    @State private var isError: Bool = false
    @State private var errorMessage: String = "Error"
    
    @ObservedObject var store = LightDetailStore()
    
    private var messageManager = MeshMessageManager()
    
    init(group: nRFMeshProvision.Group) {
        
        self.group = group
        
        messageManager.delegate = self
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
                        .tint(store.isOn ? .orange : .gray.opacity(0.5))
                        .background(.clear)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            }
            
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
                SliderView(value: $store.level, title: "Level") { isEditing in
                    levelSet()
                }
                
                SliderView(value: $store.CCT, title: "CCT") { isEditing in
                    CCTSet()
                }
                
                SliderView(value: $store.angle, title: "Angle") { isEditing in
                    angleSet()
                }
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle(group.name)
        .alert("Error", isPresented: $isError) { } message: {
            Text(errorMessage)
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
        let interval = store.isOn ? GlobalConfig.onTransition : GlobalConfig.offTransition
        let transitionTime = TransitionTime(TimeInterval(interval))
        let delay = store.isOn ? GlobalConfig.offDelay : GlobalConfig.onDelay
        let message = GenericOnOffSet(!store.isOn, transitionTime: transitionTime, delay: UInt8(delay))
        _ = try? MeshNetworkManager.instance.send(message, to: group)
        store.isOn.toggle()
    }
    
    func aiSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        let message = LuminaireAiMessage(status: store.isAi ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func sensorSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        let message = LuminaireSensorMessage(status: store.isSensor ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func levelSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        let index = Int(store.level)
        let levels = [GlobalConfig.level3, GlobalConfig.level2, GlobalConfig.level1, 100]
        let value = levels[index]
        let level = Int16(min(32767, -32768 + 655.36 * value)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func CCTSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        let index = Int(store.CCT)
        let ccts = [GlobalConfig.cct1, GlobalConfig.cct2, GlobalConfig.cct3, 100]
        let value = ccts[index]
        let colorTemperature: Int16 = Int16(value)
        let message = LuminaireColorTemperatureMessage(colorTemperature: colorTemperature)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func angleSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        let index = Int(store.angle)
        let ccts = [GlobalConfig.level3, GlobalConfig.level2, GlobalConfig.level1, 100]
        let value = ccts[index]
        let level = Int16(min(32767, -32768 + 655.36 * value)) // -32768...32767
        let message = LuminaireAngleMessage(angle: 0x0202)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
}

extension GroupDetailView: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        switch message {
        case let status as GenericOnOffStatus:
            print(status.isOn)
//            store.isOn = status.isOn
        case let status as GenericLevelStatus:
            let level = floorf(0.1 + (Float(status.level) + 32768.0) / 655.35)
            if abs(Double(level) - GlobalConfig.level1) < 5 {
                store.level = 2
            } else if abs(Double(level) - GlobalConfig.level2) < 5 {
                store.level = 1
            } else if abs(Double(level) - GlobalConfig.level3) < 5 {
                store.level = 0
            } else {
                store.level = 3
            }
        case let status as LuminaireColorTemperatureStatus:
            print(status)
        case let status as LuminaireAngleStatus:
            print(status)
        case let status as LuminaireAiStatus:
            print(status)
        case let status as LuminaireSensorStatus:
            print(status)
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
