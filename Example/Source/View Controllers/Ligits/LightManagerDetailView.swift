//
//  LightManagerDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/5.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct LightManagerDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    var node: Node
    private var messageManager = MeshMessageManager()
    @ObservedObject var store = LightDetailStore()
    
    @State var isError: Bool = false
    @State var error: ErrorType = .none
    
    @State private var onOffModel: Model?
    @State private var levelModel: Model?
    @State private var vendorModel: Model?
    @State private var sceneModel: Model?
    
    init(node: Node) {
        self.node = node
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
            
            Section {
                ForEach(store.scenes, id: \.number) { scene in
                    NavigationLink {
                        SceneLightDetailView(node: node, scene: scene)
                    } label: {
                        ItemView(resource: .icScenes24Pt, title: scene.name, detail: "Number: \(scene.number)")
                    }

                }
            } header: {
                Text("Scene")
            }
        }
        .navigationTitle(node.name ?? "Unknow")
        .toolbar(content: {
            NavigationLink("Advance", destination: NodeView(node: node)
                .navigationTitle(node.name ?? "Unknow"))
            .opacity(GlobalConfig.isShowAdvance ? 1 : 0)
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
}


extension LightManagerDetailView {
    func onAppear() {
        store.updateScene()
        messageManager.delegate = self
        onOffModel = node.primaryElement?.model(withSigModelId: .genericOnOffServerModelId)
        levelModel = node.primaryElement?.model(withSigModelId: .genericLevelServerModelId)
        vendorModel = node.primaryElement?.model(withSigModelId: .glServerModelId)
        sceneModel = node.primaryElement?.model(withSigModelId: .sceneServerModelId)
        guard MeshNetworkManager.bearer.isConnected else {
            return
        }
        bindApplicationKey()
    }
    
    func bindApplicationKey()  {
        guard let applicationKey = MeshNetworkManager.instance.meshNetwork?.applicationKey else {
            return
        }
        let models = [onOffModel, levelModel, vendorModel, sceneModel].compactMap { $0 }
        models.forEach { model in
            if model.boundApplicationKeys.isEmpty,
               let message = ConfigModelAppBind(applicationKey: applicationKey, to: model) {
                messageManager.add {
                    return try MeshNetworkManager.instance.send(message, to: self.node.primaryUnicastAddress)
                }
            }
        }
    }
    
    func aiSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        guard let vendorModel else { return }
        let message = GLAiMessage(status: store.isAi ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func sensorSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        guard let vendorModel else { return }
        let message = GLSensorMessage(status: store.isSensor ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func levelSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        guard let levelModel else { return }
//        let level = Int16(min(32767, -32768 + 655.36 * store.level)) // -32768...32767
//        let message = GenericLevelSet(level: level)
//        _ = try? MeshNetworkManager.instance.send(message, to: levelModel)
    }
    
    func glLevelsSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        guard let vendorModel else { return }
        let levels = [UInt8(store.level0), UInt8(store.level1), UInt8(store.level2), UInt8(store.level3)]
        let message = GLLevelMessage(levels: levels)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func CCTSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        guard let vendorModel else { return }
        let message = GLColorTemperatureMessage(colorTemperature:  UInt8(store.CCT))
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func runtimeSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        guard let vendorModel else { return }
        let message = GLRunTimeMessage(time: Int(store.runTime))
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func fadetimeSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        guard let vendorModel else { return }
        let message = GLFadeTimeMessage(time: Int(store.fadeTime))
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
}

extension LightManagerDetailView: MeshMessageDelegate {
    
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
            MeshNetworkManager.instance.saveModel()
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
