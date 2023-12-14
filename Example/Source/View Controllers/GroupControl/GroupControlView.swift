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
    @State private var emergencyOnOff = false
    
    @StateObject private var store = MessageDetailStore()
    
    @State private var isPresented = false
    
    private var messageManager = MeshMessageManager()

    var zone: GLZone
    
    init(zone: GLZone) {
        self.zone = zone
    }
    
    var body: some View {
        List {
            Section {
                VStack {
                    HStack {
                        onOffButton(onOff: store.isOn, title: "总开关", text: "On 开灯, AI 动作, Off 关灯,AI 不动作") {
                            store.isOn.toggle()
                            onOffSet(onOff: store.isOn, group: D000)
                        }
                        onOffButton(onOff: emergencyOnOff, title: "紧急照明", text: "On 所有灯全亮, AI 不动作, Off 回到正常") {
                            emergencyOnOff.toggle()
                            onOffSet(onOff: emergencyOnOff, group: D004)
                        }
                    }
                    HStack {
                        onOffButton(onOff: store.isSensor, title: "PIR(微波)开关", text: "On 打开, PIR 动作, Off 关掉,PIR 不动作, (内订 PIR 为打开)") {
                            store.isSensor.toggle()
                            onOffSet(onOff: store.isSensor, group: D005)
                        }
                        onOffButton(onOff: store.isAi, title: "AI 联动开关", text: " On 打开 AI, AI 动作, Off 关掉 AI,AI 不动作, (内订 AI 为打开)") {
                            store.isAi.toggle()
                            onOffSet(onOff: store.isAi, group: D006)
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
        .onAppear(perform: onAppear)
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
    
    var groups: [nRFMeshProvision.Group] {
        MeshNetworkManager.instance.meshNetwork?.groups ?? []
    }
    
    var D000: nRFMeshProvision.Group {
        let address = UInt16(zone.zone) * 16 + 0xD000
        return try! nRFMeshProvision.Group(name: "", address: address)
    }
    
    var D001: nRFMeshProvision.Group {
        let address = UInt16(zone.zone) * 16 + 0xD001
        return try! nRFMeshProvision.Group(name: "", address: address)
    }
    
    var D002: nRFMeshProvision.Group {
        let address = UInt16(zone.zone) * 16 + 0xD002
        return try! nRFMeshProvision.Group(name: "", address: address)
    }
    
    var D003: nRFMeshProvision.Group {
        let address = UInt16(zone.zone) * 16 + 0xD003
        return try! nRFMeshProvision.Group(name: "", address: address)
    }
    
    var D004: nRFMeshProvision.Group {
        let address = UInt16(zone.zone) * 16 + 0xD004
        return try! nRFMeshProvision.Group(name: "", address: address)
    }
    
    var D005: nRFMeshProvision.Group {
        let address = UInt16(zone.zone) * 16 + 0xD005
        return try! nRFMeshProvision.Group(name: "", address: address)
    }
    
    var D006: nRFMeshProvision.Group {
        let address = UInt16(zone.zone) * 16 + 0xD006
        return try! nRFMeshProvision.Group(name: "", address: address)
    }
}

extension GroupControlView {
    
    func onAppear() {
        store.isSensor = false
        store.isAi = false
        store.level = 0
//        messageManager.delegate = self
//        messageManager.add {
//            return try MeshNetworkManager.instance.send(GenericOnOffGet(), to: D000)
//        }
//        .add {
//            return try MeshNetworkManager.instance.send(GenericOnOffGet(), to: D004)
//        }
//        .add {
//            return try MeshNetworkManager.instance.send(GenericOnOffGet(), to: D005)
//        }
//        .add {
//            return try MeshNetworkManager.instance.send(GenericOnOffGet(), to: D006)
//        }
//        .add {
//            return try MeshNetworkManager.instance.send(GenericLevelGet(), to: D000)
//        }
//        .add {
//            return try MeshNetworkManager.instance.send(GenericLevelGet(), to: D001)
//        }
//        .add {
//            return try MeshNetworkManager.instance.send(GenericLevelGet(), to: D002)
//        }
    }
    
    func onOffSet(onOff: Bool, group: nRFMeshProvision.Group) {
        let message = GenericOnOffSet(onOff)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func levelSet(value: Double, group: nRFMeshProvision.Group) {
        let level = Int16(min(32767, -32768 + 655.36 * value)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func sceneRecallSet(group: nRFMeshProvision.Group?) {
        guard store.selectedScene > 0 else { return }
        guard let group else { store.selectedScene = 0; return }
        let message = SceneRecall(store.selectedScene)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
}

extension GroupControlView: MeshMessageDelegate {
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        let group = mapToGroup(source: source)
        switch message {
        case let status as GenericOnOffStatus:
            switch group {
            case D000:
                store.isOn = status.isOn
            case D004:
                store.emergencyOnOff = status.isOn
            case D005:
                store.isSensor = status.isOn
            case D006:
                store.isAi = status.isOn
            default: break
            }
            
        case let status as GenericLevelStatus:
            let level = floorf(0.1 + (Float(status.level) + 32768.0) / 655.35)
            switch group {
            case D000:
                store.level = Double(level)
            case D001:
                store.CCT = Double(level)
            case D002:
                store.angle = Double(level)
            default: break
            }
        case let status as SceneStatus:
            store.selectedScene = status.scene
            
        default: break
        }
    }
    
    func mapToGroup(source: Address) -> nRFMeshProvision.Group {
        let network = MeshNetworkManager.instance.meshNetwork!
        if let node = network.nodes.first(where: { $0.unicastAddressRange.contains(source) }),
           let group = match(node: node, source: source) {
            return group
        }
        return D000
    }
    
    func match(node: Node, source: Address) -> nRFMeshProvision.Group? {
        if [node.onOffModel, node.levelModel].contains(where: {$0?.parentElement?.unicastAddress == source }) {
            return D000
        } else if node.cctModel?.parentElement?.unicastAddress == source {
            return D001
        } else if node.angleModel?.parentElement?.unicastAddress == source {
            return D002
        } else if node.emergencyModel?.parentElement?.unicastAddress == source {
            return D004
        } else if node.pirModel?.parentElement?.unicastAddress == source {
            return D005
        } else if node.aiModel?.parentElement?.unicastAddress == source {
            return D006
        }
        return nil
    }
}
