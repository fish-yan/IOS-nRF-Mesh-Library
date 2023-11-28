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
    @StateObject var store = LightDetailStore()
    
    var body: some View {
        ControlView(messageTypes: MessageType.allCases, store: store) { messages in
            self.messages = messages
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
            saveDraft(text ?? "")
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

#Preview {
    CustomControlView()
}
