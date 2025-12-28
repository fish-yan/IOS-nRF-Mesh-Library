//
//  ProLightView.swift
//  nRF Mesh
//
//  Created by yan on 2025-12-27.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct ProLightView: View {
    @EnvironmentObject var appManager: AppManager
    
    @State var isOn: Bool?
    @State var dim: Double = 1
    @State var cct: Double = 1
    @State var angle: Double = 4/7
    @State var runTime: Double = 0
    @State var fadeTime: Double = 0
    @State var isDynamicMode: Bool?
    @State var isPresented = false
    
    @State private var sliderType: MeshSliderType = .dim
    
    @State private var isDisappear = false
    @State private var name: String = ""
    @State private var showNameAlert: Bool = false
    @State private var isOnline: Bool = false
    
    private let messageManager = MeshMessageManager()
        
    let node: Node
    var isB = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GeometryReader { reader in
                ZStack(alignment: .top) {
                    Image(.icLightLogo)
                        .resizable()
                        .frame(width: 245, height: 245)
                        .position(x: reader.size.width / 2, y: 50)
                    BeamShapeView(angle: $angle, hue: cct, brightness: $dim) {
                        angleSet()
                    } onBrightnessChange: {
                        levelSet()
                    }
                }
            }
            controlView
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button(action: {
                    showNameAlert = true
                }) {
                    HStack {
                        Text(name)
                            .font(.headline)
                        Image(systemName: "pencil")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .background(.black)
        .toolbar {
            Button(role: .destructive) {
                isPresented = true
            } label: {
                Text("Reset")
                    .underline()
                    .font(.label)
                    .foregroundStyle(.red)
            }
            .disabled(!isOnline)
            .opacity(isOnline ? 1 : 0.3)
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear(perform: onAppear)
        .onDisappear(perform: {
            isDisappear = true
        })
        .alert("警告", isPresented: $isPresented) {
            Button("取消", role: .cancel) { }
            Button("重置", role: .destructive) {
                resetNode()
            }
        } message: {
            Text("重置灯具，并将本地数据删除")
        }
        .alert("修改名称", isPresented: $showNameAlert) {
            TextField("Name", text: $name)
            Button("取消", role: .cancel) {
                name = node.name ?? "Unknow"
            }
            Button("确认", role: .destructive) {
                node.name = name
                MeshNetworkManager.instance.saveAll()
            }
        }
        .loadingable()
    }
    
    var controlView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 40) {
                COnOffItemView(isSelected: isOn == false, icon: .icAllOff, title: "OFF") {
                    isOn = false
                    onOffSet(isOn: false)
                }
                Color.accent
                    .frame(width: 1)
                COnOffItemView(isSelected: isOn == true, icon: .icAllOn, title: "ON") {
                    isOn = true
                    onOffSet(isOn: true)
                }
            }
            .padding(20)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color.itemBackground)
            .clipShape(.buttonBorder)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Mode Parameters")
                    .font(.section)
                Text("Drag to adjust the parameters of the light")
                    .font(.secondaryLabel)
                    .foregroundStyle(.secondaryLabel)
            }
            
            switch sliderType {
            case .dim:
                MeshSliderView(value: $dim, type: sliderType) {
                    levelSet()
                }
            case .cct:
                MeshSliderView(value: $cct, type: sliderType) {
                    cctSet()
                }
            case .angle:
                MeshSliderView(value: $angle, type: sliderType) {
                    angleSet()
                }
            }
            
            HStack(spacing: 0) {
                Spacer()
                item(image: .icDim, title: MeshSliderType.dim.title, isSelected: sliderType == .dim) {
                    sliderType = .dim
                }
                Spacer()
                item(image: .icCct, title:  MeshSliderType.cct.title, isSelected: sliderType == .cct) {
                    sliderType = .cct
                }
                Spacer()
                item(image: .icAngle, title:  MeshSliderType.angle.title, isSelected: sliderType == .angle) {
                    sliderType = .angle
                }
                Spacer()
            }
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryBackground)
                .ignoresSafeArea()
        )
        .toolbar(.hidden, for: .tabBar)
    }
    
    func item(image: ImageResource, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        VStack(spacing: 10) {
            Rectangle()
                .fill(isSelected ? Color.accent : Color.itemBackground)
                .overlay {
                        Image(image)
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(isSelected ? Color.whiteLabel : Color.secondaryLabel)
                }
                .frame(width: 66, height: 66)
                .clipShape(.rect(cornerRadius: 18))
                .onTapGesture(perform: action)
            Text(title)
                .font(.secondaryLabel)
                .foregroundStyle(Color.secondaryLabel)
                
        }
        .frame(maxWidth: .infinity)
    }
    
    func sliderView(title: String, value: Binding<Double>, in range: ClosedRange<Double>, onEnded: @escaping (Double) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(title): \(Int(value.wrappedValue))s")
                .font(.subheadline)
            Spacer()
                .frame(height: 3)
            CustomSlider(value: value, range: range, onEnded: onEnded)
            HStack {
                Text("\(Int(range.lowerBound))s")
                Spacer()
                Text("\(Int(range.upperBound))s")
            }
            .foregroundStyle(.secondary)
            .font(.footnote)
        }
    }
}

private extension ProLightView {

    func onAppear() {
        name = node.name ?? "Unknow"
        isDisappear = false
        messageManager.remove()
        messageManager.delegate = self
        guard let onOffModel = node.onOffModel else { return }
        _ = try? MeshNetworkManager.instance.send(GenericOnOffGet(), to: onOffModel)
    }
    
    func checkConnect() async -> Bool {
        for _ in 0..<30 {
            let connect = MeshNetworkManager.bearer.isConnected
            if connect {
                return true
            }
            try? await Task.sleep(nanoseconds: 1000000000)
        }
        return false
    }
    
    func readLevelStatus() {
        messageManager.remove()
        messageManager.add {
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
    
    func onOffSet(isOn: Bool) {
        let message = GenericOnOffSetUnacknowledged(isOn)
        guard let onOffModel = node.onOffModel else { return }
        _ = try? MeshNetworkManager.instance.send(message, to: onOffModel)
    }
    
    func levelSet() {
        print("setLevel: \(dim)")
        let level = Int16(min(32767, -32768 + 65536 * dim))
        let message = GenericLevelSetUnacknowledged(level: level)
        guard let levelModel = node.levelModel else { return }
        _ = try? MeshNetworkManager.instance.send(message, to: levelModel)
    }
    
    func cctSet() {
        print("setCCT: \(cct)")
        let level = Int16(min(32767, -32768 + 65536 * cct)) // -32768...32767
        let message = GenericLevelSetUnacknowledged(level: level)
        guard let cctModel = node.cctModel else { return }
        _ = try? MeshNetworkManager.instance.send(message, to: cctModel)
    }
    
    func angleSet() {
        let index = Int(round(angle * 7)) - 1
        let percent = [0, 0.57, 0.69, 0.74, 0.79, 0.85, 0.93][index]
        let level = Int16(min(32767, -32768 + 65536 * (1 - percent))) // -32768...32767
        let message = GenericLevelSetUnacknowledged(level: level)
        guard let angleModel = node.angleModel else { return }
        _ = try? MeshNetworkManager.instance.send(message, to: angleModel)
    }
    
    func resetNode() {
        showHUD()
        let message = ConfigNodeReset()
        _ = try? MeshNetworkManager.instance.send(message, to: node.primaryUnicastAddress)
    }
}


extension ProLightView: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        isOnline = true
        if isDisappear { return }
        switch message {
        case let status as GenericOnOffStatus:
            switch source {
            case node.onOffModel?.parentElement?.unicastAddress:
                isOn = status.isOn
                readLevelStatus()
            default: break
            }
        case let status as GenericLevelStatus:
            let level = floorf(0.1 + (Float(status.level) + 32768.0) / 655.35)
            switch source {
            case node.levelModel?.parentElement?.unicastAddress:
                withAnimation {
                    dim = Double(level)/100
                }
            case node.cctModel?.parentElement?.unicastAddress:
                withAnimation {
                    cct = Double(level)/100
                }
            case node.angleModel?.parentElement?.unicastAddress:
                withAnimation {
                    angle = Double(100-level)/100
                }
            default: break
            }
        case _ as ConfigNodeResetStatus:
            node.coordinate = nil
            let zone = GLMeshNetworkModel.instance.zone(node: node)
            zone.remove(nodeAddress: node.primaryUnicastAddress)
            GLMeshNetworkModel.instance.k9s
                .filter {$0.nodeAddress == node.primaryUnicastAddress}
                .forEach { GLMeshNetworkModel.instance.remove(k9: $0) }
            MeshNetworkManager.instance.saveAll()
            hidHUD()
            appManager.pro.popToRoot()
        default: break
        }
    }
}

#Preview {
    ProLightView(node: MeshNetworkManager.instance.meshNetwork!.nodes.first!, isB: false)
}
