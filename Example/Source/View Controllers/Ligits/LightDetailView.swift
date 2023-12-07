//
//  LightDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/21.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct LightDetailView: View {
    @Environment(\.dismiss) var dismiss
    var node: Node
    
    @ObservedObject var store = MessageDetailStore()
    
    private var messageManager = MeshMessageManager()
    
    init(node: Node) {
        self.node = node
        store.updateScene(node: node)
    }
    
    var body: some View {
        let types: [MessageType] = [.onOff, .ai, .sensor, .level, .cct, .angle]
        ControlView(messageTypes: types, store: store, onMessageChange: send)
        .navigationTitle(node.name ?? "Unknow")
        .toolbar {
            NavigationLink("Advance", destination: NodeView(node: node)
                .navigationTitle(node.name ?? "Unknow"))
            .opacity(GlobalConfig.isShowAdvance ? 1 : 0)
        }
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
    
    func send(_ message: GLMessageModel) {
        if let model = message.type.model(node: node) {
            _ = try? MeshNetworkManager.instance.send(message.message, to: model)
        }
    }
}

extension LightDetailView: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        switch message {
        case let status as GenericOnOffStatus:
            store.isOn = status.isOn
        case let status as GenericLevelStatus:
            let level = floorf(0.1 + (Float(status.level) + 32768.0) / 655.35)
            switch source {
            case node.levelModel?.parentElement?.unicastAddress:
                store.level = Double(level)
            case node.cctModel?.parentElement?.unicastAddress:
                store.CCT = Double(level)
            case node.angleModel?.parentElement?.unicastAddress:
                store.angle = Double(level)
            default: break
            }
            
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


