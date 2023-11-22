//
//  SceneLightDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct SceneGroupDetailView: View {
    @Environment(\.dismiss) var dismiss
    var group: nRFMeshProvision.Group
    var scene: nRFMeshProvision.Scene
    
    @State var isError: Bool = false
    @State var error: ErrorType = .none
    @State var isLoading: Bool = false
    
    @ObservedObject var store: GLSceneModel

    private var messageManager = MeshMessageManager()
    
    init(group: nRFMeshProvision.Group, scene: nRFMeshProvision.Scene) {
        let model = switch scene.number {
        case 1: GLSceneModel.scene1Model
        case 2: GLSceneModel.scene2Model
        case 3: GLSceneModel.scene3Model
        case 4: GLSceneModel.scene4Model
        default: scene.model ?? GLSceneModel()
        }
        self.store = model
        self.group = group
        self.scene = scene
    }
    
    var body: some View {
        List {
            Section {
                SliderView("L0", value: $store.level0)
                SliderView("L1", value: $store.level1)
                SliderView("L2", value: $store.level2)
                SliderView("L3", value: $store.level3)
                HStack {
                    Spacer()
                    Button("send", action: glLevelsSet)
                }
            } header: {
                Text("General Luminaire Level")
            }
            .buttonStyle(.borderless)
            
            Section {
                SliderView("run time", value: $store.runTime, in: 0...900, unit: "s", onDragEnd: runtimeSet)
                SliderView("fade time", value: $store.fadeTime, in: 0...60, unit: "s", onDragEnd: fadetimeSet)
            }
        }
        .navigationTitle(group.name)
        .toolbar(content: {
            Button("Save") {
                saveScene()
            }
        })
        .alert("loading...", isPresented: $isLoading, actions: { })
        .alert("Error", isPresented: $isError) {
            Button("OK") {
                switch error {
                case .bearerError:
                    dismiss.callAsFunction()
                default: break
                }
            }
        } message: {
            Text(error.message)
        }
        .onAppear(perform: onAppear)
    }
}


extension SceneGroupDetailView {
    func onAppear() {
        messageManager.delegate = self
        guard MeshNetworkManager.bearer.isConnected else {
            return
        }
    }
    
    func aiSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        let message = GLAiMessage(status: store.isAi ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func sensorSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        let message = GLSensorMessage(status: store.isSensor ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func levelSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
//        let level = Int16(min(32767, -32768 + 655.36 * store.level)) // -32768...32767
//        let message = GenericLevelSet(level: level)
//        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func glLevelsSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        let levels = [UInt8(store.level0), UInt8(store.level1), UInt8(store.level2), UInt8(store.level3)]
        let message = GLLevelMessage(levels: levels)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func CCTSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        let message = GLColorTemperatureMessage(colorTemperature:  UInt8(store.cct))
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func runtimeSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        let message = GLRunTimeMessage(time: Int(store.runTime))
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func fadetimeSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        let message = GLFadeTimeMessage(time: Int(store.fadeTime))
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func saveScene() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        
        let message = SceneStore(scene.number)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
}

extension SceneGroupDetailView: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        switch message {
        case let status as GenericLevelStatus:
            print(status)
        case let status as GLColorTemperatureStatus:
            print(status)
        case let status as GLAngleStatus:
            print(status)
        case let status as GLAiStatus:
            print(status)
        case let status as GLSensorStatus:
            print(status)
        case let status as SceneRegisterStatus:
            print(status)
//            MeshNetworkManager.instance.saveModel()
            dismiss.callAsFunction()
        default: break
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didSendMessage message: MeshMessage, from localElement: Element, to destination: MeshAddress) {
        
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager, failedToSendMessage message: MeshMessage, from localElement: Element, to destination: MeshAddress, error: Error) {
        print(message, error.localizedDescription)
//        error = .messageError(error.localizedDescription)
//        isError = true
    }
    
}
