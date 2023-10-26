//
//  LightDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/21.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

class LightDetailStore: ObservableObject {
    @Published var isOn = false
    @Published var level: Double = 100
    @Published var CCT: Double = 0
    @Published var angle: Double = 0
    @Published var isAi: Bool = true
    @Published var isSensor: Bool = true
    @Published var isError: Bool = false
    @Published var error: LightDetailView.ErrorType = .none
}

struct LightDetailView: View {
    @Environment(\.dismiss) var dismiss
    var node: Node
    @State private var onOffModel: Model?
    @State private var levelModel: Model?
    @State private var vendor: Model?
    
    @ObservedObject var store = LightDetailStore()

    private var messageManager = MeshMessageManager()
    
    init(node: Node) {
        self.node = node
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
        .navigationTitle(node.name ?? "Unknow")
        .onAppear(perform: onAppear)
        .alert("Error", isPresented: $store.isError) {
            Button("OK") {
                switch store.error {
                case .bearerError:
                    dismiss.callAsFunction()
                default: break
                }
            }
        } message: {
            Text(store.error.message)
        }
    }
}

extension LightDetailView {
    func onAppear() {
        messageManager.delegate = self
        onOffModel = node.primaryElement?.model(withSigModelId: .genericOnOffServerModelId)
        levelModel = node.primaryElement?.model(withSigModelId: .genericLevelServerModelId)
        vendor = node.primaryElement?.filteredModels().first(where: { $0.isVendor })
        guard MeshNetworkManager.bearer.isConnected else {
            return
        }
        bindApplicationKey()
        messageManager.add {
            guard let onOffModel else { return nil }
            return try MeshNetworkManager.instance.send(GenericOnOffGet(), to: onOffModel)
        }
        .add {
            guard let levelModel else { return nil }
            return try MeshNetworkManager.instance.send(GenericLevelGet(), to: levelModel)
        }
    }
    
    func bindApplicationKey()  {
        guard let applicationKey = MeshNetworkManager.instance.meshNetwork?.applicationKey else {
            return
        }
        for model in (node.primaryElement?.filteredModels() ?? []) {
            if model.boundApplicationKeys.isEmpty,
               let message = ConfigModelAppBind(applicationKey: applicationKey, to: model) {
                messageManager.add {
                    return try MeshNetworkManager.instance.send(message, to: self.node.primaryUnicastAddress)
                }
            }
        }
    }
    
    func onOffSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let onOffModel else { return }
        let interval = store.isOn ? GlobalConfig.onTransition : GlobalConfig.offTransition
        let transitionTime = TransitionTime(TimeInterval(interval))
        let delay = store.isOn ? GlobalConfig.offDelay : GlobalConfig.onDelay
        let message = GenericOnOffSet(!store.isOn, transitionTime: transitionTime, delay: UInt8(delay))
        _ = try? MeshNetworkManager.instance.send(message, to: onOffModel)
        
    }
    
    func aiSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let vendor else { return }
        let message = LuminaireAiMessage(status: store.isAi ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: vendor)
    }
    
    func sensorSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let vendor else { return }
        let message = LuminaireSensorMessage(status: store.isSensor ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: vendor)
    }
    
    func levelSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let levelModel else { return }
        let index = Int(store.level)
        let levels = [GlobalConfig.level3, GlobalConfig.level2, GlobalConfig.level1, 100]
        let value = levels[index]
        let level = Int16(min(32767, -32768 + 655.36 * value)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: levelModel)
    }
    
    func CCTSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let vendor else { return }
        let index = Int(store.CCT)
        let ccts = [GlobalConfig.cct1, GlobalConfig.cct2, GlobalConfig.cct3, 100]
        let value = ccts[index]
        let colorTemperature: Int16 = Int16(value)
        let message = LuminaireColorTemperatureMessage(colorTemperature: colorTemperature)
        _ = try? MeshNetworkManager.instance.send(message, to: vendor)
    }
    
    func angleSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let vendor else { return }
        let index = Int(store.angle)
        let ccts = [GlobalConfig.level3, GlobalConfig.level2, GlobalConfig.level1, 100]
        let value = ccts[index]
        let level = Int16(min(32767, -32768 + 655.36 * value)) // -32768...32767
        let message = LuminaireAngleMessage(angle: 0x0202)
        _ = try? MeshNetworkManager.instance.send(message, to: vendor)
    }
}

extension LightDetailView: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        switch message {
        case let status as GenericOnOffStatus:
            store.isOn = status.isOn
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

extension LightDetailView {
    enum ErrorType {
        case none
        case messageError(_ value: String)
        case bearerError
        
        var message: String {
            switch self {
            case .none:
                ""
            case .messageError(let value):
                value
            case .bearerError:
                "bearer is not connected"
            }
        }
    }
}

private extension Model {
    
    var isVendor: Bool {
        return !isBluetoothSIGAssigned   // Vendor Models.
            || modelIdentifier == .genericOnOffServerModelId
            || modelIdentifier == .genericPowerOnOffServerModelId
            || modelIdentifier == .genericPowerOnOffSetupServerModelId
            || modelIdentifier == .genericLevelServerModelId
            || modelIdentifier == .genericDefaultTransitionTimeServerModelId
    }
    
}
