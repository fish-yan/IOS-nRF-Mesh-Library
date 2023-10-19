//
//  LightDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/21.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct LightDetailView: View {
    
    var node: Node
    private var onOffModel: Model?
    private var levelModel: Model?
    private var CCTModel: Model?
    private var angleModel: Model?
    
    @State private var isOn = false
    @State private var level: Double = 0
    @State private var CCT: Double = 0
    @State private var directions: CGPoint = .zero
    
    @State private var isError: Bool = false
    @State private var errorMessage: String = "Error"
    
    private var messageManager = MeshMessageManager()
    
    init(node: Node) {
        
        self.node = node
        let models = node.primaryElement?.models ?? []
        onOffModel = models.first(where: {$0.modelIdentifier == .genericOnOffServerModelId})
        levelModel = models.first(where: {$0.modelIdentifier == .genericLevelServerModelId})
        CCTModel = models.first(where: {$0.modelIdentifier == .genericLevelServerModelId})
        angleModel = models.first(where: {$0.modelIdentifier == .genericLevelServerModelId})
        
        messageManager.delegate = self
    }
    
    var body: some View {
        List {
            Section {
                Button {
                    onOffSet(turnOn: isOn)
                } label: {
                    Image(systemName: "power.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .tint(isOn ? .orange : .gray.opacity(0.5))
                        .background(.clear)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            }
            
            Section {
                SliderView(value: $level, title: "亮度调节") { isEditing in
                    levelSet(value: level)
                }
                
                SliderView(value: $CCT, title: "色温调节") { isEditing in
                    CCTSet(value: CCT)
                }
            }
            
            Section {
                DirectionControlView(onChange: directionSet)
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle(node.name ?? "Unknow")
        .onAppear(perform: onAppear)
        .alert("Error", isPresented: $isError) { } message: {
            Text(errorMessage)
        }

    }
}

extension LightDetailView {
    func onAppear() {
        messageManager.start {
            bindApplicationKey()
        }
        .then {
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
                if let message = ConfigModelAppBind(applicationKey: applicationKey, to: model) {
                    messageManager.then {
                        return try MeshNetworkManager.instance.send(message, to: self.node.primaryUnicastAddress)
                    }
                }
            }
        }
        messageManager.done()
    }
    
    func onOffSet(turnOn: Bool) {
        guard let onOffModel else { return }
        let transitionTime = GlobalConfig.transitionTime(turnOn)
        let delay = GlobalConfig.delay(turnOn)
        let message = GenericOnOffSet(turnOn, transitionTime: transitionTime, delay: delay)
        _ = try? MeshNetworkManager.instance.send(message, to: onOffModel)
        
    }
    
    func levelSet(value: Double) {
        guard let levelModel else { return }
        let percent: Double = 30
        let level = Int16(min(32767, -32768 + 655.36 * percent)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: levelModel)
    }
    
    func CCTSet(value: Double) {
        guard let levelModel else { return }
        let percent: Double = 30
        let level = Int16(min(32767, -32768 + 655.36 * percent)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: levelModel)
    }
    
    func directionSet(value: Direction) {
        var x = directions.x
        var y = directions.y
        switch value {
        case .up: y += 1
        case .left: x -= 1
        case .down: y -= 1
        case .right: x += 1
        }
        directions = CGPoint(x: x, y: y)
    }
}

extension LightDetailView: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        switch message {
        case let status as GenericOnOffStatus:
            isOn = status.isOn
        case let status as GenericLevelStatus:
            let l = floorf(0.1 + (Float(status.level) + 32768.0) / 655.35)
            level = Double(l)
        default: break
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didSendMessage message: MeshMessage, from localElement: Element, to destination: MeshAddress) {
        
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager, failedToSendMessage message: MeshMessage, from localElement: Element, to destination: MeshAddress, error: Error) {
        errorMessage = error.localizedDescription
        isError = true
    }
    
}
