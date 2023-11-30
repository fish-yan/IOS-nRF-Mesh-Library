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
                    DestinationView(messages: messages(with: draft))
                } label: {
                    VStack(alignment: .leading) {
                        Text(draft.name)
                            .font(.headline)
                            .foregroundStyle(Color(uiColor: .label))
                        Spacer().frame(height: 10)
                        HStack {
                            VStack(alignment: .leading) {
                                ForEach(draft.messageTypes, id: \.self) { type in
                                    Text(type.name + ":")
                                }
                            }
                            .frame(width: 100)
                            VStack(alignment: .leading) {
                                ForEach(draft.messageTypes, id: \.self) { type in
                                    switch type {
                                    case .ai:
                                        Text(draft.store.isAi ? "on" : "off")
                                    case .sensor:
                                        Text(draft.store.isSensor ? "on" : "off")
                                    case .level:
                                        Text("\(draft.store.level, specifier: "%.f")%")
                                    case .cct:
                                        Text("\(draft.store.CCT, specifier: "%.f")%")
                                    case .angle:
                                        Text("\(draft.store.angle, specifier: "%.f")%")
                                    case .glLevel:
                                        Text("\(draft.store.level0, specifier: "%.f")% \(draft.store.level1, specifier: "%.f")% \(draft.store.level2, specifier: "%.f")% \(draft.store.level3, specifier: "%.f")%")
                                    case .runTime:
                                        Text("\(draft.store.runTime, specifier: "%.f")")
                                    case .fadeTime:
                                        Text("\(draft.store.fadeTime, specifier: "%.f")")
                                    case .sceneStore:
                                        Text("\(draft.store.selectedScene)")
                                    default: Text("none")
                                    }
                                }
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
    
    func messages(with draft: GLDraftModel) -> [GLMessageModel] {
        let store = draft.store
        let types = draft.messageTypes
        var messages = [GLMessageModel]()
        func updateMessage(type: MessageType, message: MeshMessage) {
            messages.removeAll(where: { $0.type == type })
            let model = GLMessageModel(type: type, message: message)
            messages.append(model)
        }
        for type in types {
            switch type {
            case .ai:
                let ai = GLAiMessage(status: store.isAi ? .on : .off)
                updateMessage(type: .ai, message: ai)
            case .sensor:
                let sensor = GLSensorMessage(status: store.isSensor ? .on : .off)
                updateMessage(type: .sensor, message: sensor)
            case .level:
                let levelValue = Int16(min(32767, -32768 + 655.36 * store.level)) // -32768...32767
                let level = GenericLevelSet(level: levelValue)
                updateMessage(type: .level, message: level)
            case .cct:
                let cctValue = Int16(min(32767, -32768 + 655.36 * store.CCT)) // -32768...32767
                let cct = GenericLevelSet(level: cctValue)
                updateMessage(type: .cct, message: cct)
            case .angle:
                let angleValue = Int16(min(32767, -32768 + 655.36 * store.angle)) // -32768...32767
                let angle = GenericLevelSet(level: angleValue)
                updateMessage(type: .angle, message: angle)
            case .glLevel:
                let levelValues = [UInt8(store.level0), UInt8(store.level1), UInt8(store.level2), UInt8(store.level3)]
                let levels = GLLevelMessage(levels: levelValues)
                updateMessage(type: .glLevel, message: levels)
            case .runTime:
                let runTime = GLRunTimeMessage(time: Int(store.runTime))
                updateMessage(type: .runTime, message: runTime)
            case .fadeTime:
                let fadeTime = GLFadeTimeMessage(time: Int(store.fadeTime))
                updateMessage(type: .fadeTime, message: fadeTime)
            case .sceneStore:
                if store.selectedScene > 0 {
                    let selectedScene = SceneStore(store.selectedScene)
                    updateMessage(type: .sceneStore, message: selectedScene)
                }
            default: break
            }
        }
        return messages
    }
}
