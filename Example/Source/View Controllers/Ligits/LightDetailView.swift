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
    @Published var level0: Double = 100
    @Published var level1: Double = 70
    @Published var level2: Double = 50
    @Published var level3: Double = 20
    @Published var runTime: Double = 300
    @Published var fadeTime: Double = 60
    @Published var CCT: Double = 0
    @Published var angle: Double = 0
    @Published var isAi: Bool = true
    @Published var isSensor: Bool = true
    @Published var selectedScene: SceneNumber = 0
    
    @Published var isError: Bool = false
    @Published var error: ErrorType = .none
    
    @Published var scenes: [nRFMeshProvision.Scene] = []
    
    func updateScene(node: Node) {
        scenes = node.scenes
    }
}

struct LightDetailView: View {
    @Environment(\.dismiss) var dismiss
    var node: Node
    @State var scenes: [nRFMeshProvision.Scene] = []
    
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
                SliderView("Level", value: $store.level, onDragEnd:  {
                    levelSet()
                })
                
                SliderView("CCT", value: $store.CCT, onDragEnd:  {
                    CCTSet()
                })
            }
            Section {
                ForEach(scenes, id: \.number) { scene in
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
        scenes = node.scenes
        guard MeshNetworkManager.bearer.isConnected else {
            return
        }
        messageManager.add {
            guard let onOffModel = node.onOffModel else { return nil }
            return try MeshNetworkManager.instance.send(GenericOnOffGet(), to: onOffModel)
        }
        .add {
            guard let levelModel = node.levelModel else { return nil }
            return try MeshNetworkManager.instance.send(GenericLevelGet(), to: levelModel)
        }
    }
    
    func onOffSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let onOffModel = node.onOffModel else { return }
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
        guard let vendorModel = node.vendorModel else { return }
        let message = GLAiMessage(status: store.isAi ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func sensorSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let vendorModel = node.vendorModel else { return }
        let message = GLSensorMessage(status: store.isSensor ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func levelSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let levelModel = node.levelModel else { return }
        let level = Int16(min(32767, -32768 + 655.36 * store.level)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: levelModel)
    }
    
    func CCTSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let cctModel = node.cctModel else { return }
        let level = Int16(min(32767, -32768 + 655.36 * store.level)) // -32768...32767
        let message = GenericLevelSet(level: level)
//        let message = GLColorTemperatureMessage(colorTemperature: UInt8(store.CCT))
        _ = try? MeshNetworkManager.instance.send(message, to: cctModel)
    }
    
    func sceneSet(_ scene: nRFMeshProvision.Scene) {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let sceneModel = node.sceneModel else { return }
        let message = SceneRecall(scene.number)
        _ = try? MeshNetworkManager.instance.send(message, to: sceneModel)
    }
}

extension LightDetailView: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        switch message {
        case let status as GenericOnOffStatus:
            store.isOn = status.isOn
        case let status as GenericLevelStatus:
            let level = floorf(0.1 + (Float(status.level) + 32768.0) / 655.35)
//            store.level = Double(level)
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


