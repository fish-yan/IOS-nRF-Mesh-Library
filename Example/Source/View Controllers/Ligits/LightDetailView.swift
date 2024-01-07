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
    @State var isShowAdvance = false
    
    @State private var messageManager = MeshMessageManager()
    
    init(node: Node) {
        self.node = node
        store.updateScene(node: node)
    }
    
    var body: some View {
        let types: [MessageType] = [.onOff, .ai, .sensor, .level, .cct, .angle]
        ControlView(messageTypes: types, store: store, onMessageChange: send)
        .navigationTitle(node.name ?? "Unknow")
        .toolbar {
            NavigationLink("Advance", destination: {
                NodeView(node: node, resetCallback: {
                    dismiss.callAsFunction()
                })
                .navigationTitle(node.name ?? "Unknow")
            })
            .opacity(isShowAdvance ? 1 : 0)
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
        isShowAdvance = GlobalConfig.isShowAdvance
        messageManager = MeshMessageManager()
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
        .add {
            guard let cctModel = node.cctModel else { return nil }
            return try MeshNetworkManager.instance.send(GenericLevelGet(), to: cctModel)
        }
        .add {
            guard let angleModel = node.angleModel else { return nil }
            return try MeshNetworkManager.instance.send(GenericLevelGet(), to: angleModel)
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
        print("aa:message:\(message), source: \(source)")
        switch message {
        case let status as GenericOnOffStatus:
            switch source {
            case node.onOffModel?.parentElement?.unicastAddress:
                store.isOn = status.isOn
            default: break
            }
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
        default: break
        }
    }
}


