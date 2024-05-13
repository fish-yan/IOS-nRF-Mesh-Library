//
//  GroupControlView.swift
//  nRF Mesh
//
//  Created by yan on 2023/12/1.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct GroupControlView: View {
        
    @State private var isPresented = false
    
    @ObservedObject var zone: GLZone
    
    @ObservedObject var store: MessageDetailStore
    
    init(zone: GLZone) {
        self.zone = zone
        self.store = zone.store
    }
    
    var body: some View {
        List {
            Section {
                VStack {
                    HStack {
                        onOffButton(onOff: store.isOn == true, title: "总开关", text: "On 开灯, AI 动作, Off 关灯,AI 不动作") {
                            if store.isOn == true {
                                store.isOn = false
                            } else {
                                store.isOn = true
                            }
                            onOffSet(onOff: store.isOn == true, group: D000)
                        }
                        onOffButton(onOff: store.emergencyOnOff, title: "紧急照明", text: "On 所有灯全亮, AI 不动作, Off 回到正常") {
                            store.emergencyOnOff.toggle()
                            onOffSet(onOff: store.emergencyOnOff, group: D004)
                        }
                    }
                    HStack {
                        onOffButton(onOff: store.isSensor, title: "PIR(微波)开关", text: "On 打开, PIR 动作, Off 关掉,PIR 不动作, (内订 PIR 为打开)") {
                            store.isSensor.toggle()
                            pirOnOff(onOff: store.isSensor)
//                            onOffSet(onOff: store.isSensor, group: D005)
                        }
                        onOffButton(onOff: store.isAi, title: "AI 联动开关", text: " On 打开 AI, AI 动作, Off 关掉 AI,AI 不动作, (内订 AI 为打开)") {
                            store.isAi.toggle()
                            aiOnOff(onOff: store.isAi)
//                            onOffSet(onOff: store.isAi, group: D006)
                        }
                    }
                }
            } header: {
                Text("on/off")
            }
            .buttonStyle(.borderless)
            
            Section {
                SliderView("Level", value: $store.level) { isEditing in
                    levelSet(value: store.level, group: D000)
                }
                SliderView("CCT", value: $store.CCT) { isEditing in
                    levelSet(value: store.CCT, group: D001)
                }
                SliderView("Angle", value: $store.angle) { isEditing in
                    levelSet(value: store.angle, group: D002)
                }
            } header: {
                Text("Level")
            }
            
            Section {
                let scenes = MeshNetworkManager.defaultSceneAddresses
                ForEach(scenes, id: \.self) { scene in
                    HStack {
                        Text("Scene \(scene)")
                        Spacer()
                        Button {
                            store.selectedScene = SceneNumber(scene)
                            isPresented = true
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.headline)
                                .opacity(store.selectedScene == scene ? 1 : 0)
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
            Button("Cancel", role: .cancel) {
                store.selectedScene = 0
            }
        } message: {
            Text("发送指令到 所有灯/Arcosense灯/Arcospace灯")
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
        .frame(maxWidth: .infinity)
    }
    
    var groups: [NordicMesh.Group] {
        MeshNetworkManager.instance.meshNetwork?.groups ?? []
    }
    
    var D000: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD000
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D001: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD001
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D002: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD002
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D003: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD003
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D004: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD004
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D005: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD005
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D006: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD006
        return try! NordicMesh.Group(name: "", address: address)
    }
}

extension GroupControlView {
    
    func onOffSet(onOff: Bool, group: NordicMesh.Group) {
        let message = GenericOnOffSet(onOff)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
        MeshNetworkManager.instance.saveModel()
    }
    
    func pirOnOff(onOff: Bool) {
        let status = GLSimpleStatus(bool: onOff)
        let message = GLSensorMessage(status: status)
        _ = try? MeshNetworkManager.instance.send(message, to: D000)
        MeshNetworkManager.instance.saveModel()
    }
    
    func aiOnOff(onOff: Bool) {
        let status = GLSimpleStatus(bool: onOff)
        let message = GLAiMessage(status: status)
        _ = try? MeshNetworkManager.instance.send(message, to: D000)
        MeshNetworkManager.instance.saveModel()
    }
    
    func levelSet(value: Double, group: NordicMesh.Group) {
        let level = Int16(min(32767, -32768 + 655.36 * value)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
        MeshNetworkManager.instance.saveModel()
    }
    
    func sceneRecallSet(group: NordicMesh.Group?) {
        guard store.selectedScene > 0 else { return }
        guard let group else { store.selectedScene = 0; return }
        let message = SceneRecall(store.selectedScene)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
        MeshNetworkManager.instance.saveModel()
    }
    
}
