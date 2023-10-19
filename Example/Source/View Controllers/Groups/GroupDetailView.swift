//
//  LightDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/21.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct GroupDetailView: View {
    
    var group: nRFMeshProvision.Group
        
    @State private var isOn = false
    @State private var level: Double = 0
    @State private var CCT: Double = 0
    @State private var directions: CGPoint = .zero
    
    @State private var isError: Bool = false
    @State private var errorMessage: String = "Error"
    
    private var messageManager = MeshMessageManager()
    
    init(group: nRFMeshProvision.Group) {
        
        self.group = group
        
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
        .navigationTitle(group.name)
        .alert("Error", isPresented: $isError) { } message: {
            Text(errorMessage)
        }

    }
}

extension GroupDetailView {
    
    func onOffSet(turnOn: Bool) {
        guard let applicationKey = MeshNetworkManager.instance.meshNetwork?.models(subscribedTo: group).first?.boundApplicationKeys.first else {
            return
        }

        let transitionTime = GlobalConfig.transitionTime(turnOn)
        let delay = GlobalConfig.delay(turnOn)
        let message = GenericOnOffSet(turnOn, transitionTime: transitionTime, delay: delay)
        _ = try? MeshNetworkManager.instance.send(message, to: group, using: applicationKey)
        
    }
    
    func levelSet(value: Double) {
        guard let applicationKey = MeshNetworkManager.instance.meshNetwork?.models(subscribedTo: group).first?.boundApplicationKeys.first else {
            return
        }
        let percent: Double = 30
        let level = Int16(min(32767, -32768 + 655.36 * percent)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: group, using: applicationKey)
    }
    
    func CCTSet(value: Double) {
        guard let applicationKey = MeshNetworkManager.instance.meshNetwork?.models(subscribedTo: group).first?.boundApplicationKeys.first else {
            return
        }
        let percent: Double = 30
        let level = Int16(min(32767, -32768 + 655.36 * percent)) // -32768...32767
        let message = GenericLevelSet(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: group, using: applicationKey)
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

extension GroupDetailView: MeshMessageDelegate {
    
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
