//
//  GroupControlView.swift
//  nRF Mesh
//
//  Created by yan on 2023/12/1.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct GroupControlView: View {
    @State private var allOnOff = false
    @State private var emergencyOnOff = false
    @State private var PIROnOff = false
    @State private var AIOnOff = false
    @State private var level: Double = 0
    @State private var cct: Double = 0
    @State private var angle: Double = 0
    @State private var selectedScene: SceneNumber = 0
    @State private var isPresented = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack {
                        HStack {
                            onOffButton(onOff: allOnOff, title: "总开关", text: "On 开灯, AI 动作, Off 关灯,AI 不动作") {
                                allOnOff.toggle()
                                onOffSet(onOff: allOnOff, group: D000)
                            }
                            onOffButton(onOff: emergencyOnOff, title: "紧急照明", text: "On 所有灯全亮, AI 不动作, Off 回到正常") {
                                emergencyOnOff.toggle()
                                onOffSet(onOff: emergencyOnOff, group: D004)
                            }
                        }
                        HStack {
                            onOffButton(onOff: PIROnOff, title: "PIR(微波)开关", text: "On 打开, PIR 动作, Off 关掉,PIR 不动作, (内订 PIR 为打开)") {
                                PIROnOff.toggle()
                                onOffSet(onOff: PIROnOff, group: D005)
                            }
                            onOffButton(onOff: AIOnOff, title: "AI 联动开关", text: " On 打开 AI, AI 动作, Off 关掉 AI,AI 不动作, (内订 AI 为打开)") {
                                AIOnOff.toggle()
                                onOffSet(onOff: AIOnOff, group: D006)
                            }
                        }
                    }
                } header: {
                    Text("on/off")
                }
                .buttonStyle(.borderless)
                
                Section {
                    SliderView("Level", value: $level) { isEditing in
                        levelSet(value: level, group: D000)
                    }
                    SliderView("CCT", value: $cct) { isEditing in
                        levelSet(value: cct, group: D001)
                    }
                    SliderView("Angle", value: $angle) { isEditing in
                        levelSet(value: angle, group: D002)
                    }
                } header: {
                    Text("Level")
                }
                
                Section {
                    ForEach(1...4, id: \.self) { scene in
                        HStack {
                            Text("Scene \(scene)")
                            Spacer()
                            Button {
                                selectedScene = SceneNumber(scene)
                                isPresented = true
                            } label: {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                                    .opacity(selectedScene == scene ? 1 : 0)
                            }
                        }
                    }
                } header: {
                    Text("scene")
                }
            }
            .navigationTitle("Control")
            .alert("Set Scene To Lights", isPresented: $isPresented) {
                Button("All") {
                    sceneRecallSet(group: D000)
                }
                Button("Arcosense") {
                    sceneRecallSet(group: D001)
                }
                Button("Arcospace") {
                    sceneRecallSet(group: D002)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("发送指令到 所有灯/Arcosense灯/Arcospace灯")
            }
        }
    }
    
    func onOffButton(onOff: Bool, title: String, text: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "power.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .tint(onOff ? .orange : .gray.opacity(0.5))
                    .background(.clear)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color(uiColor: UIColor.label))
                Text(text)
                    .font(.system(size: 10))
                    .foregroundStyle(Color(uiColor: UIColor.secondaryLabel))
                    .lineLimit(10)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(10)
    }
    
    var groups: [nRFMeshProvision.Group] {
        MeshNetworkManager.instance.meshNetwork?.groups ?? []
    }
    
    var D000: nRFMeshProvision.Group {
        groups.first(where: { $0.address.hex == "D000" })!
    }
    
    var D001: nRFMeshProvision.Group {
        groups.first(where: { $0.address.hex == "D001" })!
    }
    
    var D002: nRFMeshProvision.Group {
        groups.first(where: { $0.address.hex == "D002" })!
    }
    
    var D003: nRFMeshProvision.Group {
        groups.first(where: { $0.address.hex == "D003" })!
    }
    
    var D004: nRFMeshProvision.Group {
        groups.first(where: { $0.address.hex == "D004" })!
    }
    
    var D005: nRFMeshProvision.Group {
        groups.first(where: { $0.address.hex == "D005" })!
    }
    
    var D006: nRFMeshProvision.Group {
        groups.first(where: { $0.address.hex == "D006" })!
    }
}

extension GroupControlView {
    func onOffSet(onOff: Bool, group: nRFMeshProvision.Group) {
        let message = GenericOnOffSet(onOff)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func levelSet(value: Double, group: nRFMeshProvision.Group) {
        let level = Int16(min(32767, -32768 + 655.36 * value)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func sceneRecallSet(group: nRFMeshProvision.Group) {
        guard selectedScene > 0 else { return }
        let message = SceneRecall(selectedScene)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
}
