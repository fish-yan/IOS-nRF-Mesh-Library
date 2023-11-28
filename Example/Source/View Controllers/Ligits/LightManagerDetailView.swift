//
//  LightManagerDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/5.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct LightManagerDetailView: View {    
    var node: Node
    private var messageManager = MeshMessageManager()
    @ObservedObject var store = MessageDetailStore()
    
    @State var isError: Bool = false
    @State var error: ErrorType = .none
    
    init(node: Node) {
        self.node = node
    }
    
    var body: some View {
        List {
            Section {
                SliderView("L0", value: $store.level0)
                SliderView("L1", value: $store.level1)
                SliderView("L2", value: $store.level2)
                SliderView("L3", value: $store.level3)
                HStack {
                    Spacer()
                    Button("send", action: glLevelsSet)
                }
            } header: {
                Text("General Luminaire Level")
            }
            .buttonStyle(.borderless)
            
            Section {
                SliderView("run time", value: $store.runTime, in: 0...900, unit: "s", onDragEnd: runtimeSet)
                SliderView("fade time", value: $store.fadeTime, in: 0...60, unit: "s", onDragEnd: fadetimeSet)
            }
            
            Section {
                ForEach(store.scenes, id: \.number) { scene in
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
                .onDelete(perform: delete)
            } header: {
                HStack {
                    Text("Scene")
                    Spacer()
                    NavigationLink {
                        LightStoreSceneView(node: node, selectedScene: $store.selectedScene)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .navigationTitle(node.name ?? "Unknow")
        .toolbar(content: {
            NavigationLink("Advance", destination: NodeView(node: node)
                .navigationTitle(node.name ?? "Unknow"))
            .opacity(GlobalConfig.isShowAdvance ? 1 : 0)
        })
        .alert("Error", isPresented: $store.isError) {
            Button("OK") {}
        } message: {
            Text(store.error.message)
        }
        .onAppear(perform: onAppear)
    }
}


extension LightManagerDetailView {
    func onAppear() {
        store.updateScene(node: node)
        messageManager.delegate = self
    }
        
    func aiSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        guard let vendorModel = node.vendorModel else { return }
        let message = GLAiMessage(status: store.isAi ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func sensorSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        guard let vendorModel = node.vendorModel else { return }
        let message = GLSensorMessage(status: store.isSensor ? .on : .off)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func levelSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        guard let levelModel = node.levelModel else { return }
//        let level = Int16(min(32767, -32768 + 655.36 * store.level)) // -32768...32767
//        let message = GenericLevelSet(level: level)
//        _ = try? MeshNetworkManager.instance.send(message, to: levelModel)
    }
    
    func glLevelsSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        guard let vendorModel = node.vendorModel else { return }
        let levels = [UInt8(store.level0), UInt8(store.level1), UInt8(store.level2), UInt8(store.level3)]
        let message = GLLevelMessage(levels: levels)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func runtimeSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        guard let vendorModel = node.vendorModel else { return }
        let message = GLRunTimeMessage(time: Int(store.runTime))
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func fadetimeSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            isError = true
            error = .bearerError
            return
        }
        guard let vendorModel = node.vendorModel else { return }
        let message = GLFadeTimeMessage(time: Int(store.fadeTime))
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func sceneSet(_ scene: nRFMeshProvision.Scene) {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let sceneModel = node.sceneModel else { return }
        let message = SceneRecall(scene.number)
        _ = try? MeshNetworkManager.instance.send(message, to: sceneModel)
    }
    
    func delete(indexSet: IndexSet) {
        guard let index = indexSet.min(),
              let sceneSetupModel = node.sceneSetupModel else {
            return
        }
        let scene = store.scenes[index]
        store.scenes.remove(atOffsets: indexSet)
        let message = SceneDelete(scene.number)
        _ = try? MeshNetworkManager.instance.send(message, to: sceneSetupModel)
    }
}

extension LightManagerDetailView: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        switch message {
        case let status as GenericLevelStatus:
            print(status)
        case let status as GLColorTemperatureStatus:
            print(status)
        case let status as GLAngleStatus:
            print(status)
        case let status as GLAiStatus:
            print(status)
        case let status as GLSensorStatus:
            print(status)
        case let status as SceneStatus:
            store.selectedScene = status.scene
        case let status as SceneRegisterStatus:
            print(status)
//            MeshNetworkManager.instance.saveModel()
//            dismiss.callAsFunction()
        default: break
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didSendMessage message: MeshMessage, from localElement: Element, to destination: MeshAddress) {
        
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager, failedToSendMessage message: MeshMessage, from localElement: Element, to destination: MeshAddress, error: Error) {
        print(message, error.localizedDescription)
//        error = .messageError(error.localizedDescription)
//        isError = true
    }
    
}
