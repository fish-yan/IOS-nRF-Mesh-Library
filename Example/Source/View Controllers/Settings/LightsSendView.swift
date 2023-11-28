//
//  LightsSendView.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct LightsSendView: View {
    
    let messages: [GLMessageModel]
    
    @State var multiSelected: Set<Node> = []
    
    @State private var editMode: EditMode = .active
    
    @State private var nodes = [Node]()
    
    @State private var isPresented = false
    
    @State private var alertMessage = "122333"
    
    private var messageManager = MeshMessageManager()
    
    init(messages: [GLMessageModel]) {
        self.messages = messages
    }
    
    var body: some View {
        List(selection: $multiSelected) {
            Section {
                ForEach(nodes, id: \.self) { node in
                    VStack(alignment: .leading) {
                        Text(node.name ?? "Unknow")
                            .font(.headline)
                        Text("Address: 0x\(node.primaryUnicastAddress.hex)")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
            } header: {
                Text("Lights")
            } footer: {
                Text("Select the target lights to send")
            }
        }
        .alert(isPresented: $isPresented) {
            Alert(title: Text("Sending messages..."), message: Text(alertMessage))
        }
        .navigationTitle("Lights")
        .onAppear(perform: onAppear)
        .environment(\.editMode, $editMode)
        .toolbar {
            Button("Send", action: sendAction)
        }
    }
}


private extension LightsSendView {
    func onAppear() {
        nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner }
        messageManager.delegate = self
    }
    func sendAction() {
        isPresented = true
        for node in multiSelected {
            for message in self.messages {
                var model: Model?
                var modelName = ""
                switch message.type {
                case .onOff:
                    model = node.onOffModel
                    modelName = "onOff"
                case .level:
                    model = node.levelModel
                    modelName = "level"
                case .cct:
                    model = node.cctModel
                    modelName = "cct"
                case .angle:
                    model = node.angleModel
                    modelName = "angle"
                case .sceneStore:
                    model = node.sceneSetupModel
                    modelName = "sceneSetup"
                case .ai, .sensor, .glLevel, .fadeTime, .runTime:
                    model = node.vendorModel
                    modelName = "vendor"
                }
                if let model {
                    messageManager.add {
                        alertMessage = "send \(message.type.name) message to node:\(node.name ?? "Unknow") on \(modelName) model"
                        return try MeshNetworkManager.instance.send(message.message, to: model)
                    }
                }
            }
        }
        messageManager.completion {
            isPresented = false
            alertMessage = ""
        }
    }
}

extension LightsSendView: MeshMessageDelegate {
    func meshNetworkManager(_ manager: nRFMeshProvision.MeshNetworkManager, didReceiveMessage message: nRFMeshProvision.MeshMessage, sentFrom source: nRFMeshProvision.Address, to destination: nRFMeshProvision.MeshAddress) {
        
    }
}
