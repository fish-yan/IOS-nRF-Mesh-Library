//
//  LightControlView.swift
//  nRF Mesh
//
//  Created by yan on 2024/1/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct LightControlView: View {
    var node: Node
    let dims = [0, 0.05, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.85, 1]
    // 2500 2700 3000 3500 4000 5000
    let ccts = [0, 0.08, 0.2, 0.4, 0.6, 1]
    @State var dim: Double = 0
    @State var cct: Double = 0
    @State var angle: Double = 0
    @State var tdim: Double = 0
    @State var tcct: Double = 0
    @State var tangle: Double = 0
    @State var isOn: Bool = false
    @State private var messageManager = MeshMessageManager()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                ZStack(alignment: .top) {
                    BeamShapeView(angle: $angle, endValue: $tangle, hue: cct, brightness: dim)

                    HStack {
                        VerticalControl(type: .dim, value: $dim, endValue: $tdim, onAdd: {
                            if let next = dims.first(where: {$0 > dim}) {
                                dim = next
                            }
                        }, onSubtract: {
                            if let next = dims.last(where: {$0 < dim}) {
                                dim = next
                            }
                        })
                        DotView(value: dimDot)
                        Spacer()
                        DotView(value: cctDot)
                        VerticalControl(type: .cct, value: $cct, endValue: $tcct, onAdd: {
                            if let next = ccts.first(where: {$0 > cct}) {
                                cct = next
                            }
                        }, onSubtract: {
                            if let next = ccts.last(where: {$0 < cct}) {
                                cct = next
                            }
                        })
                    }
                    .padding(20)

                    Image(.iconLight)
                        .resizable()
                        .frame(width: 150, height: 110)
                        .padding(.top, 20)
                        
                }
                Spacer().frame(height: 30)
                Button("", systemImage: "power", action: {
                    onOffSet()
                })
                .font(.system(size: 60, weight: .bold))
                .foregroundStyle(isOn ? .orange : .white)
                .frame(height: 80)
                Spacer().frame(height: 30)
            }
        }
        .onAppear(perform: onAppear)
        .onChange(of: dim) { oldValue, newValue in
            debouncer.call {
                self.levelSet()
            }
        }
        .onChange(of: cct) { oldValue, newValue in
            debouncer.call {
                self.cctSet()
            }
        }
        .onChange(of: angle) { oldValue, newValue in
            debouncer.call {
                self.angleSet()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var dimDot: Double {
        let index = nearIndex(arr: dims, value: dim)
        return Double(index + 1) / 12 * 6
    }
    
    var cctDot: Double {
        let index = nearIndex(arr: ccts, value: cct)
        return Double(index + 1)
    }
    
    func nearIndex(arr: [Double], value: Double) -> Int {
        let nexIndex = arr.firstIndex(where: {$0 >= value}) ?? 0
        guard nexIndex > 0 else {
            return nexIndex
        }
        let prevIndex = nexIndex - 1
        if arr[nexIndex] - value >= value - arr[prevIndex] {
            return prevIndex
        } else {
            return nexIndex
        }
    }
}

extension LightControlView {
    func onAppear() {
        messageManager = MeshMessageManager()
        messageManager.delegate = self
        guard MeshNetworkManager.bearer.isConnected else {
            return
        }
        messageManager.add {
            guard let onOffModel = node.onOffModel else { return nil }
            return try MeshNetworkManager.instance.send(GenericOnOffGet(), to: onOffModel)
        }
        .add {
            guard let cctModel = node.cctModel else { return nil }
            return try MeshNetworkManager.instance.send(GenericLevelGet(), to: cctModel)
        }
        .add {
            guard let angleModel = node.angleModel else { return nil }
            return try MeshNetworkManager.instance.send(GenericLevelGet(), to: angleModel)
        }
        .add {
            guard let levelModel = node.levelModel else { return nil }
            return try MeshNetworkManager.instance.send(GenericLevelGet(), to: levelModel)
        }
    }
    
    func onOffSet() {
        isOn.toggle()
        messageManager.add {
            let message = GenericOnOffSet(isOn)
            guard let onOffModel = node.onOffModel else { return nil }
            return try MeshNetworkManager.instance.send(message, to: onOffModel)
        }
    }
    
    func levelSet() {
        messageManager.add {
            let level = Int16(min(32767, -32768 + 65536 * dim)) // -32768...32767
            let message = GenericLevelSet(level: level)
            guard let levelModel = node.levelModel else { return nil }
            return try MeshNetworkManager.instance.send(message, to: levelModel)
        }
    }
    
    func cctSet() {
        messageManager.add {
            let level = Int16(min(32767, -32768 + 65536 * (1 - cct))) // -32768...32767
            let message = GenericLevelSet(level: level)
            guard let cctModel = node.cctModel else { return nil }
            return try MeshNetworkManager.instance.send(message, to: cctModel)
        }
    }
    func angleSet() {
        messageManager.add {
            let level = Int16(min(32767, -32768 + 65536 * (1 - angle))) // -32768...32767
            let message = GenericLevelSet(level: level)
            guard let angleModel = node.angleModel else { return nil }
            return try MeshNetworkManager.instance.send(message, to: angleModel)
        }
    }
}

extension LightControlView: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        switch message {
        case let status as GenericOnOffStatus:
            switch source {
            case node.onOffModel?.parentElement?.unicastAddress:
                isOn = status.isOn
                guard let levelModel = node.levelModel else { return }
                _ = try? MeshNetworkManager.instance.send(GenericLevelGet(), to: levelModel)
            default: break
            }
        case let status as GenericLevelStatus:
            let level = floorf(0.1 + (Float(status.level) + 32768.0) / 655.35)
            withAnimation {
                switch source {
                case node.levelModel?.parentElement?.unicastAddress:
                    dim = Double(level)/100
                    tdim = Double(level)/100
                    isOn = dim != 0
                case node.cctModel?.parentElement?.unicastAddress:
                    cct = Double(100-level)/100
                    tcct = Double(100-level)/100
                case node.angleModel?.parentElement?.unicastAddress:
                    angle = Double(100-level)/100
                    tangle = Double(100-level)/100
                default: break
                }
            }
        default: break
        }
    }
}


