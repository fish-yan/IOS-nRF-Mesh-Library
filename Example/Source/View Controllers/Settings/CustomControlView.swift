//
//  CustomControlView.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct CustomControlView: View {
    @Environment(\.dismiss) private var dismiss
    @State var messages: [GLMessageModel] = []
    @State var isPresented = false
    @State var name = ""
    @StateObject var store = MessageDetailStore()
    
    var body: some View {
        let types: [MessageType] = [.ai, .sensor, .level, .cct, .angle, .glLevel, .runTime, .fadeTime, .sceneStore]
        ControlView(messageTypes: types, store: store) { message in
            messages.removeAll(where: { $0.type == message.type })
            messages.append(message)
        }
        .navigationTitle("Custom Control")
        .toolbar {
            HStack {
                Button("Save draft") {
                    isPresented = true
                }
                NavigationLink("Next") {
                    DestinationView(messages: messages)
                }
            }
        }
        .textFieldAlert(isPresented: $isPresented, title: "Please input name", text: "", placeholder: "name", action: { text in
            if let text {
                saveDraft(text)
            }
        })
    }
}

private extension CustomControlView {
    func saveDraft(_ name: String) {
        let draft = GLDraftModel(name: name, store: store)
        GLMeshNetworkModel.instance.drafts.append(draft)
        MeshNetworkManager.instance.saveModel()
        dismiss.callAsFunction()
    }
}
