//
//  DraftControlView.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/27.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct DraftControlView: View {
    var messages: [GLMessageModel] {
        var messages = [GLMessageModel]()
        func updateMessage(type: MessageType, message: MeshMessage) {
            messages.removeAll(where: { $0.type == type })
            let model = GLMessageModel(type: type, message: message)
            messages.append(model)
        }
        
        let ai = GLAiMessage(status: store.isAi ? .on : .off)
        updateMessage(type: .ai, message: ai)
        
        let sensor = GLSensorMessage(status: store.isSensor ? .on : .off)
        updateMessage(type: .sensor, message: sensor)
        
        let levelValue = Int16(min(32767, -32768 + 655.36 * store.level)) // -32768...32767
        let level = GenericLevelSet(level: levelValue)
        updateMessage(type: .level, message: level)
        
        let cctValue = Int16(min(32767, -32768 + 655.36 * store.CCT)) // -32768...32767
        let cct = GenericLevelSet(level: cctValue)
        updateMessage(type: .cct, message: cct)
        
        let angleValue = Int16(min(32767, -32768 + 655.36 * store.angle)) // -32768...32767
        let angle = GenericLevelSet(level: angleValue)
        updateMessage(type: .angle, message: angle)
        
        let levelValues = [UInt8(store.level0), UInt8(store.level1), UInt8(store.level2), UInt8(store.level3)]
        let levels = GLLevelMessage(levels: levelValues)
        updateMessage(type: .glLevel, message: levels)
        
        let runTime = GLRunTimeMessage(time: Int(store.runTime))
        updateMessage(type: .runTime, message: runTime)
        
        let fadeTime = GLFadeTimeMessage(time: Int(store.fadeTime))
        updateMessage(type: .fadeTime, message: fadeTime)
        
        let selectedScene = SceneStore(store.selectedScene)
        updateMessage(type: .sceneStore, message: selectedScene)
        return messages
    }
    @State var isPresented = false
    @State var name = ""
    @ObservedObject var store = MessageDetailStore()
    
    init(store: MessageDetailStore) {
        self.store = store
    }
    
    var body: some View {
        let types: [MessageType] = [.ai, .sensor, .level, .cct, .angle, .glLevel, .runTime, .fadeTime, .sceneStore]
        ControlView(messageTypes: types, store: store)
        .navigationTitle("Draft Control")
        .toolbar {
            HStack {
                NavigationLink("Next") {
                    DestinationView(messages: messages)
                }
            }
        }
    }
}
