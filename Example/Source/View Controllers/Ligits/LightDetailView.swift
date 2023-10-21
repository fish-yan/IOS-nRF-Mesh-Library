//
//  LightDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/21.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

class LightDetailStore: ObservableObject {
    @Published var isOn = false
    @Published var level: Double = 100
    @Published var CCT: Double = 0
    @Published var directions: CGPoint = .zero
    @Published var isError: Bool = false
    @Published var error: LightDetailView.ErrorType = .none
}

struct LightDetailView: View {
    @Environment(\.dismiss) var dismiss
    var node: Node
    @State private var onOffModel: Model?
    @State private var levelModel: Model?
    @State private var CCTModel: Model?
    @State private var angleModel: Model?
    
    @ObservedObject var store = LightDetailStore()

    private var messageManager = MeshMessageManager()
    
    init(node: Node) {
        self.node = node
    }
    
    var body: some View {
        List {
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
            
            Section {
                SliderView(value: $store.level, title: "Level") { isEditing in
                    levelSet()
                }
                
                SliderView(value: $store.CCT, title: "CCT") { isEditing in
                    CCTSet()
                }
            }
            
            Section {
                DirectionControlView(onChange: directionSet)
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle(node.name ?? "Unknow")
        .onAppear(perform: onAppear)
        .alert("Error", isPresented: $store.isError) {
            Button("OK") {
                switch store.error {
                case .bearerError:
                    dismiss.callAsFunction()
                default: break
                }
            }
        } message: {
            Text(store.error.message)
        }
    }
}

extension LightDetailView {
    func onAppear() {
        messageManager.delegate = self
        let models = node.primaryElement?.models ?? []
        onOffModel = models.first(where: {$0.modelIdentifier == .genericOnOffServerModelId})
        levelModel = models.first(where: {$0.modelIdentifier == .genericLevelServerModelId})
        CCTModel = models.first(where: {$0.modelIdentifier == .genericLevelServerModelId})
        angleModel = models.first(where: {$0.modelIdentifier == .genericLevelServerModelId})
        print(node.elements.flatMap({$0.models}))
        guard MeshNetworkManager.bearer.isConnected else {
            return
        }
//        messageManager.start {
//            bindApplicationKey()
//        }
        messageManager.start {
            guard let onOffModel else { return nil }
            return try MeshNetworkManager.instance.send(GenericOnOffGet(), to: onOffModel)
        }
        .then {
            guard let levelModel else { return nil }
            return try MeshNetworkManager.instance.send(GenericLevelGet(), to: levelModel)
        }
    }
    
    func bindApplicationKey()  {
        let applicationKey = MeshNetworkManager.instance.meshNetwork!.applicationKeys.notKnownTo(node: node).filter{ self.node.knows(networkKey: $0.boundNetworkKey) }.first
        guard let applicationKey else {
            messageManager.done()
            return
        }
        for element in node.elements {
            element.models.forEach { model in
                if model.boundApplicationKeys.isEmpty,
                   let message = ConfigModelAppBind(applicationKey: applicationKey, to: model) {
                    messageManager.then {
                        return try MeshNetworkManager.instance.send(message, to: self.node.primaryUnicastAddress)
                    }
                }
            }
        }
        messageManager.done()
    }
    
    func onOffSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let onOffModel else { return }
        let transitionTime = GlobalConfig.transitionTime(!store.isOn)
        let delay = GlobalConfig.delay(!store.isOn)
        let message = GenericOnOffSet(!store.isOn, transitionTime: transitionTime, delay: delay)
        _ = try? MeshNetworkManager.instance.send(message, to: onOffModel)
        
    }
    
    func levelSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let levelModel else { return }
        let index = Int(store.level)
        let levels = [GlobalConfig.level3, GlobalConfig.level2, GlobalConfig.level1, 100]
        let value = levels[index]
        let level = Int16(min(32767, -32768 + 655.36 * value)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: levelModel)
    }
    
    func CCTSet() {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        guard let levelModel else { return }
        let index = Int(store.level)
        let value = 30.0
        let level = Int16(min(32767, -32768 + 655.36 * value)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: levelModel)
    }
    
    func directionSet(value: Direction) {
        guard MeshNetworkManager.bearer.isConnected else {
            store.isError = true
            store.error = .bearerError
            return
        }
        var x = store.directions.x
        var y = store.directions.y
        switch value {
        case .up: y += 1
        case .left: x -= 1
        case .down: y -= 1
        case .right: x += 1
        }
        store.directions = CGPoint(x: x, y: y)
    }
}

extension LightDetailView: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        switch message {
        case let status as GenericOnOffStatus:
            store.isOn = status.isOn
        case let status as GenericLevelStatus:
            let level = floorf(0.1 + (Float(status.level) + 32768.0) / 655.35)
            if abs(Double(level) - GlobalConfig.level1) < 5 {
                store.level = 2
            } else if abs(Double(level) - GlobalConfig.level2) < 5 {
                store.level = 1
            } else if abs(Double(level) - GlobalConfig.level3) < 5 {
                store.level = 0
            } else {
                store.level = 3
            }
        default: break
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didSendMessage message: MeshMessage, from localElement: Element, to destination: MeshAddress) {
        
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager, failedToSendMessage message: MeshMessage, from localElement: Element, to destination: MeshAddress, error: Error) {
        store.error = .messageError(error.localizedDescription)
        store.isError = true
    }
    
}

extension LightDetailView {
    enum ErrorType {
        case none
        case messageError(_ value: String)
        case bearerError
        
        var message: String {
            switch self {
            case .none:
                ""
            case .messageError(let value):
                value
            case .bearerError:
                "bearer is not connected"
            }
        }
    }
}
