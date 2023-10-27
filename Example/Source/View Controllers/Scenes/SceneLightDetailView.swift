//
//  SceneLightDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct SceneLightDetailView: View {
    @Environment(\.dismiss) var dismiss
    var node: Node
    @State private var onOffModel: Model?
    @State private var levelModel: Model?
    @State private var vendorModel: Model?
    
    @ObservedObject var store = LightDetailStore()

    private var messageManager = MeshMessageManager()
    
    init(node: Node) {
        self.node = node
    }
    
    var body: some View {
        List {
            Section {
                sliderView("L0", value: $store.level0)
                sliderView("L1", value: $store.level1)
                sliderView("L2", value: $store.level2)
                sliderView("L3", value: $store.level3)
                HStack {
                    Spacer()
                    Button("send", action: glLevelsSet)
                }
            } header: {
                Text("General Luminaire Level")
            }
            
            Section {
                sliderView("rum time", value: $store.runTime, in: 0...900, unit: "s")
                sliderView("fade time", value: $store.fadeTime, in: 0...60, unit: "s")
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle(node.name ?? "Unknow")
        .toolbar(content: {
            Button("Save") {
                dismiss.callAsFunction()
            }
        })
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
        .onAppear(perform: onAppear)
    }
    
    private func sliderView(_ text: String, value: Binding<Double>, in bounds: ClosedRange<Double> = 0...100, unit: String = "%") -> some View {
        VStack(alignment: .leading, content: {
            Text("\(text): \(String(format: "%.f", value.wrappedValue))\(unit)")
            Slider<Text, Text>(
                value: value,
                in: bounds,
                step: 1,
                minimumValueLabel: Text("\(String(format: "%.f", bounds.lowerBound))"),
                maximumValueLabel: Text("\(String(format: "%.f", bounds.upperBound))"),
                label: { Text(text) }
            )
        })
    }
}


extension SceneLightDetailView {
    func onAppear() {
        messageManager.delegate = self
        onOffModel = node.primaryElement?.model(withSigModelId: .genericOnOffServerModelId)
        levelModel = node.primaryElement?.model(withSigModelId: .genericLevelServerModelId)
        vendorModel = node.primaryElement?.model(withSigModelId: .glServerModelId)
        guard MeshNetworkManager.bearer.isConnected else {
            return
        }
        bindApplicationKey()
    }
    
    func bindApplicationKey()  {
        guard let applicationKey = MeshNetworkManager.instance.meshNetwork?.applicationKey else {
            return
        }
        if let model = node.primaryElement?.model(withSigModelId: .sceneServerModelId),
           model.boundApplicationKeys.isEmpty,
           let message = ConfigModelAppBind(applicationKey: applicationKey, to: model) {
            messageManager.add {
                return try MeshNetworkManager.instance.send(message, to: self.node.primaryUnicastAddress)
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
        guard let vendorModel else { return }
        let message = GLAiMessage(status: store.isAi ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func sensorSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let vendorModel else { return }
        let message = GLSensorMessage(status: store.isSensor ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func levelSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let levelModel else { return }
        let index = Int(store.level)
        let levels = [GlobalConfig.level3, GlobalConfig.level2, GlobalConfig.level1, GlobalConfig.level0]
        let value = levels[index]
        let level = Int16(min(32767, -32768 + 655.36 * value)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: levelModel)
    }
    
    func glLevelsSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let vendorModel else { return }
        let levels = [UInt8(store.level0), UInt8(store.level1), UInt8(store.level2), UInt8(store.level3)]
        let message = GLLevelMessage(levels: levels)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func CCTSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let vendorModel else { return }
        let index = Int(store.CCT)
        let ccts = [GlobalConfig.cct0, GlobalConfig.cct1, GlobalConfig.cct2, GlobalConfig.cct3]
        let value = ccts[index]
        let colorTemperature = UInt8(value)
        let message = GLColorTemperatureMessage(colorTemperature: colorTemperature)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func angleSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let vendorModel else { return }
        let index = Int(store.angle)
        let ccts = [GlobalConfig.level3, GlobalConfig.level2, GlobalConfig.level1, 100]
        let value = ccts[index]
        let level = Int16(min(32767, -32768 + 655.36 * value)) // -32768...32767
        let message = GLAngleMessage(angle: 0x02)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
}

extension SceneLightDetailView: MeshMessageDelegate {
    
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
        case let status as GLColorTemperatureStatus:
            print(status)
        case let status as GLAngleStatus:
            print(status)
        case let status as GLAiStatus:
            print(status)
        case let status as GLSensorStatus:
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
