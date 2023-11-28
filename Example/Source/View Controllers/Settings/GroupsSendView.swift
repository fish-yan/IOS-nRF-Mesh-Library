//
//  GroupsSendView.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct GroupsSendView: View {
    
    let messages: [GLMessageModel]
    
    @State var multiSelected: Set<nRFMeshProvision.Group> = []
    
    @State private var editMode: EditMode = .active
    
    @State private var groups = [nRFMeshProvision.Group]()
    
    @State private var isPresented = false
    
    @State private var alertMessage = ""
    
    private var messageManager = MeshMessageManager()
    
    init(messages: [GLMessageModel]) {
        self.messages = messages
    }
    
    var body: some View {
        List(selection: $multiSelected) {
            Section {
                ForEach(groups, id: \.self) { group in
                    VStack(alignment: .leading) {
                        Text(group.name)
                            .font(.headline)
                        Text("Address: 0x\(group.address.hex)")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
            } header: {
                Text("Groups")
            } footer: {
                Text("Select the target groups to send")
            }
        }
        .alert(isPresented: $isPresented) {
            Alert(title: Text("Sending messages..."), message: Text(alertMessage))
        }
        .navigationTitle("Groups")
        .onAppear(perform: onAppear)
        .environment(\.editMode, $editMode)
        .toolbar {
            Button("Send", action: sendAction)
        }
    }
}


private extension GroupsSendView {
    func onAppear() {
        groups = MeshNetworkManager.instance.meshNetwork?.groups ?? []
        messageManager.delegate = self
    }
    func sendAction() {
        isPresented = true
        for group in multiSelected {
            for message in self.messages {
                switch message.type {
                case .cct, .angle: // 不支持
                    continue
                default: break
                }
                messageManager.add {
                    alertMessage = "send \(message.type.name) message to node:\(group.name)"
                    return try MeshNetworkManager.instance.send(message.message, to: group)
                }
            }
        }
        messageManager.completion {
            isPresented = false
            alertMessage = ""
        }
    }
}

extension GroupsSendView: MeshMessageDelegate {
    func meshNetworkManager(_ manager: nRFMeshProvision.MeshNetworkManager, didReceiveMessage message: nRFMeshProvision.MeshMessage, sentFrom source: nRFMeshProvision.Address, to destination: nRFMeshProvision.MeshAddress) {
        
    }
}
