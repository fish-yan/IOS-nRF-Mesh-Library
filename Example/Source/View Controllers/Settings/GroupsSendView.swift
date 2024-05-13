//
//  GroupsSendView.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct GroupsSendView: View {
    
    let messages: [GLMessageModel]
    
    @State var multiSelected: Set<NordicMesh.Group> = []
    
    @State private var editMode: EditMode = .active
    
    @State private var groups = [NordicMesh.Group]()
    
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
        var isFirst = true
        for group in multiSelected {
            for message in self.messages {
                switch message.type {
                case .cct, .angle: // 不支持
                    continue
                default: break
                }
                messageManager.addWithoutHandle {
                    alertMessage = "send \(message.type.name) message to node:\(group.name)"
                    let needWait = !isFirst && message.message is GLMessage
                    let deadline: DispatchTime = needWait ? .now() + 6 : .now() + 2
                    DispatchQueue.main.asyncAfter(deadline: deadline) {
                        _ = try? MeshNetworkManager.instance.send(message.message, to: group)
                    }
                    isFirst = false
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
    func meshNetworkManager(_ manager: NordicMesh.MeshNetworkManager, didReceiveMessage message: NordicMesh.MeshMessage, sentFrom source: NordicMesh.Address, to destination: NordicMesh.MeshAddress) {
        
    }
}
