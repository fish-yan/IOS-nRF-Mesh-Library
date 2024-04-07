//
//  CLightView.swift
//  test
//
//  Created by yan on 2024/3/30.
//

import SwiftUI
import nRFMeshProvision

struct CLightView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var isOn: Bool?
    @State var dim: Double = 1
    @State var cct: Double = 0.5
    @State var angle: Double = 0.5
    
    @State private var sliderType: MeshSliderType = .dim
    
    @State private var messageManager = MeshMessageManager()
    
    let node: Node
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: 10)
            Button("Lights", systemImage: "chevron.left", action: backAction)
                .font(.label)
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                .background(
                    Color.tertiaryBackground
                        .clipShape(.rect(bottomTrailingRadius: 16, topTrailingRadius: 16))
                )
            GeometryReader { reader in
                ZStack(alignment: .top) {
                    Image(.icLightLogo)
                        .resizable()
                        .frame(width: 245, height: 245)
                        .position(x: reader.size.width / 2, y: 50)
                    BeamShapeView(angle: $angle, hue: cct, brightness: dim)
                }
            }
            controlView
        }
        .background(.black)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: onAppear)
    }
    
    var controlView: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack(spacing: 40) {
                COnOffItemView(isSelected: isOn == false, icon: .icAllOff, title: "Close") {
                    isOn = false
                    onOffSet(isOn: false)
                }
                Color.accent
                    .frame(width: 1)
                COnOffItemView(isSelected: isOn == true, icon: .icAllOn, title: "Open") {
                    isOn = true
                    onOffSet(isOn: true)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color(uiColor: UIColor(resource: .itemBackground)))
            .clipShape(.buttonBorder)
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
            
            Text("Mode")
                .font(.section)
            HStack() {
                item(image: .icDim, title: MeshSliderType.dim.title, isSelected: sliderType == .dim) {
                    sliderType = .dim
                }
                item(image: .icCct, title:  MeshSliderType.cct.title, isSelected: sliderType == .cct) {
                    sliderType = .cct
                }
                item(image: .icAngle, title:  MeshSliderType.angle.title, isSelected: sliderType == .angle) {
                    sliderType = .angle
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryBackground)
                .ignoresSafeArea()
        )
    }
    
    func item(image: ImageResource, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Rectangle()
            .fill(isSelected ? Color.accent : Color.itemBackground)
            .overlay {
                VStack(spacing: 20) {
                    Image(image)
                        .resizable()
                        .frame(width: 28, height: 28)
                    Text(title)
                        .font(.secondaryLabel)
                }
                .foregroundStyle(isSelected ? Color.whiteLabel : Color.secondaryLabel)
            }
        .frame(height: 140)
        .clipShape(.rect(cornerRadius: 18))
        .onTapGesture(perform: action)
    }
}

private extension CLightView {
    
    func backAction() {
        dismiss.callAsFunction()
    }
    
    func onAppear() {
        messageManager = MeshMessageManager()
        messageManager.remove()
        messageManager.delegate = self
//        guard let onOffModel = node.onOffModel else { return }
//        _ = try? MeshNetworkManager.instance.send(GenericOnOffGet(), to: onOffModel)
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
        let message = GenericOnOffSet(isOn)
        guard let onOffModel = node.onOffModel else { return }
        _ = try? MeshNetworkManager.instance.send(message, to: onOffModel)
    }
    
    func levelSet() {
        let level = Int16(min(32767, -32768 + 65536 * dim)) // -32768...32767
        let message = GenericLevelSet(level: level)
        guard let levelModel = node.levelModel else { return }
        _ = try? MeshNetworkManager.instance.send(message, to: levelModel)
    }
    
    func cctSet() {
        let level = Int16(min(32767, -32768 + 65536 * (1 - cct))) // -32768...32767
        let message = GenericLevelSet(level: level)
        guard let cctModel = node.cctModel else { return }
        _ = try? MeshNetworkManager.instance.send(message, to: cctModel)
    }
    func angleSet() {
        let level = Int16(min(32767, -32768 + 65536 * (1 - angle))) // -32768...32767
        let message = GenericLevelSet(level: level)
        guard let angleModel = node.angleModel else { return }
        _ = try? MeshNetworkManager.instance.send(message, to: angleModel)
    }
}


extension CLightView: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
        switch message {
        case let status as GenericOnOffStatus:
            switch source {
            case node.onOffModel?.parentElement?.unicastAddress:
                isOn = status.isOn
//                readLevelStatus()
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
                    cct = Double(100-level)/100
                }
            case node.angleModel?.parentElement?.unicastAddress:
                withAnimation {
                    angle = max(Double(100-level)/100, 0.1667)
                }
            default: break
            }
        default: break
        }
    }
}




#Preview {
    CLightView(node: MeshNetworkManager.instance.meshNetwork!.nodes.first!)
}
