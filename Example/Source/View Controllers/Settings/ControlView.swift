//
//  ControlView.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

enum MessageType: CaseIterable, Codable {
    case onOff, ai, sensor, level, cct, angle, glLevel, runTime, fadeTime, sceneStore
    var name: String {
        switch self {
        case .onOff: "onOff"
        case .ai: "ai"
        case .sensor: "sensor"
        case .level: "level"
        case .cct: "cct"
        case .angle: "angle"
        case .glLevel: "glLevel"
        case .runTime: "runTime"
        case .fadeTime: "fadeTime"
        case .sceneStore: "sceneStore"
        }
    }
}

struct ControlView: View {
    
    @ObservedObject private var store: LightDetailStore
    
    @State private var messageTypes: [MessageType]
    
    @State private var messages: [GLMessageModel] = []
    
    @State private var onMessageChange: (([GLMessageModel]) -> Void)
    
    init(messageTypes: [MessageType], store: LightDetailStore, onMessageChange: @escaping ([GLMessageModel]) -> Void = { _ in }) {
        self.messageTypes = messageTypes
        self.store = store
        self.onMessageChange = onMessageChange
    }
    
    var body: some View {
        List {
            if messageTypes.contains(.onOff) {
                onOffView
            }
            
            Section {
                if messageTypes.contains(.ai) {
                    aiView
                }
                if messageTypes.contains(.sensor) {
                    sensorView
                }
            }
            
            Section {
                if messageTypes.contains(.level) {
                    levelView
                }
                if messageTypes.contains(.cct) {
                    cctView
                }
                if messageTypes.contains(.angle) {
                    angleView
                }
            }
            
            if messageTypes.contains(.glLevel) {
                glLevelView
            }
            
            Section {
                if messageTypes.contains(.runTime) {
                    runTimeView
                }
                if messageTypes.contains(.fadeTime) {
                    fadeTimeView
                }
            }
            
            if messageTypes.contains(.sceneStore) {
                allScenesView
            }
        }
    }
    
    private var onOffView: some View {
        Section {
            Button {
                onOffSet()
            } label: {
                Image(systemName: "power.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .tint(store.isOn ? .orange : .gray.opacity(0.5))
                    .background(.clear)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
        }
        .buttonStyle(.borderless)
    }
    
    private var aiView: some View {
        Toggle("AI", isOn: $store.isAi)
            .onChange(of: store.isAi) { value in
                aiSet()
            }
    }
    
    private var sensorView: some View {
        Toggle("Sensor", isOn: $store.isSensor)
            .onChange(of: store.isSensor) { value in
                sensorSet()
            }
    }
    
    private var levelView: some View {
        SliderView("Level", value: $store.level, onDragEnd:  {
            levelSet()
        })
    }
    
    private var cctView: some View {
        SliderView("CCT", value: $store.CCT, onDragEnd:  {
            cctSet()
        })
    }
    
    private var angleView: some View {
        SliderView("angle", value: $store.angle, onDragEnd:  {
            angleSet()
        })
    }
    
    private var glLevelView: some View {
        Section {
            SliderView("L0", value: $store.level0, onDragEnd:  {
                glLevelsSet()
            })
            SliderView("L1", value: $store.level1, onDragEnd:  {
                glLevelsSet()
            })
            SliderView("L2", value: $store.level2, onDragEnd:  {
                glLevelsSet()
            })
            SliderView("L3", value: $store.level3, onDragEnd:  {
                glLevelsSet()
            })
        } header: {
            Text("General Luminaire Level")
        }
        .buttonStyle(.borderless)
    }
    
    private var runTimeView: some View {
        SliderView("run time", value: $store.runTime, in: 0...900, unit: "s", onDragEnd: runTimeSet)
    }
    
    private var fadeTimeView: some View {
        SliderView("fade time", value: $store.fadeTime, in: 0...60, unit: "s", onDragEnd: fadeTimeSet)
    }
    
    private var allScenesView: some View {
        Section {
            ForEach(store.allScenes, id: \.number) { scene in
                HStack {
                    Text(scene.name)
                    Spacer()
                    Button {
                        sceneSet(scene)
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .opacity(store.selectedScene == scene.number ? 1 : 0)
                    }
                }
            }
        } header: {
            Text("Scene Store")
        } footer: {
            Text("select scene and store to node or group")
        }
    }
}

private extension ControlView {
    func onOffSet() {
        store.isOn.toggle()
        let message = GenericOnOffSet(store.isOn)
        updateMessage(type: .onOff, message: message)
    }
    
    func aiSet() {
        let message = GLAiMessage(status: store.isAi ? .on : .off)
        updateMessage(type: .ai, message: message)
    }
    
    func sensorSet() {
        let message = GLSensorMessage(status: store.isSensor ? .on : .off)
        updateMessage(type: .sensor, message: message)
    }
    
    func levelSet() {
        let level = Int16(min(32767, -32768 + 655.36 * store.level)) // -32768...32767
        let message = GenericLevelSet(level: level)
        updateMessage(type: .level, message: message)
    }
    
    func cctSet() {
        let level = Int16(min(32767, -32768 + 655.36 * store.CCT)) // -32768...32767
        let message = GenericLevelSet(level: level)
        updateMessage(type: .cct, message: message)
    }
    func angleSet() {
        let level = Int16(min(32767, -32768 + 655.36 * store.angle)) // -32768...32767
        let message = GenericLevelSet(level: level)
        updateMessage(type: .angle, message: message)
    }
    
    func glLevelsSet() {
        let levels = [UInt8(store.level0), UInt8(store.level1), UInt8(store.level2), UInt8(store.level3)]
        let message = GLLevelMessage(levels: levels)
        updateMessage(type: .glLevel, message: message)
    }
    
    func runTimeSet() {
        let message = GLRunTimeMessage(time: Int(store.runTime))
        updateMessage(type: .runTime, message: message)
    }
    
    func fadeTimeSet() {
        let message = GLFadeTimeMessage(time: Int(store.fadeTime))
        updateMessage(type: .fadeTime, message: message)
    }
    
    func sceneSet(_ scene: nRFMeshProvision.Scene) {
        store.selectedScene = scene.number
        let message = SceneStore(scene.number)
        updateMessage(type: .sceneStore, message: message)
    }
    
    func updateMessage(type: MessageType, message: MeshMessage) {
        messages.removeAll(where: { $0.type == type })
        let model = GLMessageModel(type: type, message: message)
        messages.append(model)
        onMessageChange(messages)
    }
}
