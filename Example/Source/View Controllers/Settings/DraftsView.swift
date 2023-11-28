//
//  DraftsView.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/27.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct DraftsView: View {

    var body: some View {
        List {
            ForEach(GLMeshNetworkModel.instance.drafts, id: \.self) { draft in
                NavigationLink {
//                    DraftControlView(store: draft.store)
                    DestinationView(messages: messages(with: draft.store))
                } label: {
                    VStack(alignment: .leading) {
                        Text(draft.name)
                            .font(.headline)
                            .foregroundStyle(Color(uiColor: .label))
                        Spacer().frame(height: 10)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("ai:")
                                Text("sensor:")
                                Text("level:")
                                Text("cct:")
                                Text("levels:")
                                Text("runTime:")
                                Text("fadeTime:")
                                Text("scene:")
                            }
                            .frame(width: 100)
                            VStack(alignment: .leading) {
                                Text(draft.store.isAi ? "on" : "off")
                                Text(draft.store.isSensor ? "on" : "off")
                                Text("\(draft.store.level, specifier: "%.f")%")
                                Text("\(draft.store.CCT, specifier: "%.f")%")
                                Text("\(draft.store.level0, specifier: "%.f")% \(draft.store.level1, specifier: "%.f")% \(draft.store.level2, specifier: "%.f")% \(draft.store.level3, specifier: "%.f")%")
                                Text("\(draft.store.runTime, specifier: "%.f")")
                                Text("\(draft.store.fadeTime, specifier: "%.f")")
                                Text("\(draft.store.selectedScene)")
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        
                    }
                }
                
            }
            .onDelete(perform: onDelete)
        }
        .navigationTitle("Drafts")
    }
    
    func onDelete(indexSet: IndexSet) {
        GLMeshNetworkModel.instance.drafts.remove(atOffsets: indexSet)
        MeshNetworkManager.instance.saveModel()
    }
    
    func messages(with store: MessageDetailStore) -> [GLMessageModel] {
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
        
        if store.selectedScene > 0 {
            let selectedScene = SceneStore(store.selectedScene)
            updateMessage(type: .sceneStore, message: selectedScene)
        }
        return messages
    }
}
