//
//  CLightView.swift
//  test
//
//  Created by yan on 2024/3/30.
//

import SwiftUI
import NordicMesh

struct CLightView: View {
    @EnvironmentObject var appManager: AppManager
    
    @State var isOn: Bool?
    @State var dim: Double = 1
    @State var cct: Double = 0.5
    @State var angle: Double = 0.5
    @State var runTime: Double = 0
    @State var fadeTime: Double = 0
    @State var isDynamicMode: Bool?
    @State var isPresented = false
    
    @State private var sliderType: MeshSliderType = .dim
    
    private let messageManager = MeshMessageManager()
    
    private let taskManager = MeshTaskManager()
    
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
                    BeamShapeView(angle: $angle, hue: cct, brightness: dim)
                }
            }
            controlView
        }
        .background(.black)
        .toolbar {
            TooBarBackItem()
        }
        .toolbar {
            if isB {
                NavigationLink(value: NavPath.bSceneStoreNodeView(node: node)) {
                    Text("Save")
                        .underline()
                        .font(.label)
                        .foregroundStyle(.white)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: onAppear)
        .alert("Warning", isPresented: $isPresented) {
            Button("Cancel", role: .cancel) { }
            Button("Turn off") {
                isDynamicMode = false
                pirOnOff(onOff: false)
            }
        } message: {
            Text("To save the scene, you need to turn off the dynamic mode first.")
        }
        .loadingable()
    }
    
    var controlView: some View {
        VStack(alignment: .leading, spacing: 20) {
            if isB {
                VStack(spacing: 10) {
                    HStack(spacing: 30) {
                        COnOffItemView(isSelected: isDynamicMode == false, icon: .ibDynamicOff, title: "OFF") {
                            isDynamicMode = false
                            pirOnOff(onOff: false)
                        }
                        Text("Dynamic mode")
                            .font(.label)
                            .frame(width: 130)
                        COnOffItemView(isSelected: isDynamicMode == true, icon: .ibDynamicOn, title: "ON") {
                            isDynamicMode = true
                            pirOnOff(onOff: true)
                        }
                    }
                    .padding(20)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.itemBackground)
                    .clipShape(.buttonBorder)
//                    sliderView(title: "Run time", value: $runTime, in: 0...900) {_ in
//                        runtimeSet()
//                    }
//                    sliderView(title: "Fade time", value: $fadeTime, in: 0...60) {_ in
//                        fadetimeSet()
//                    }
                }
            } else {
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
                .padding(20)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color.itemBackground)
                .clipShape(.buttonBorder)
            }
            
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

private extension CLightView {

    func onAppear() {
        messageManager.remove()
        messageManager.delegate = self
        if isB {
            isPresented = true
        } else {
            guard let onOffModel = node.onOffModel else { return }
            _ = try? MeshNetworkManager.instance.send(GenericOnOffGet(), to: onOffModel)
        }
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
        let level = Int16(min(32767, -32768 + 65536 * dim))
        let message = GenericLevelSetUnacknowledged(level: level)
        guard let levelModel = node.levelModel else { return }
        _ = try? MeshNetworkManager.instance.send(message, to: levelModel)
    }
    
    func cctSet() {
        let level = Int16(min(32767, -32768 + 65536 * cct)) // -32768...32767
        let message = GenericLevelSetUnacknowledged(level: level)
        guard let cctModel = node.cctModel else { return }
        _ = try? MeshNetworkManager.instance.send(message, to: cctModel)
    }
    
    func angleSet() {
        let level = Int16(min(32767, -32768 + 65536 * (1 - angle))) // -32768...32767
        let message = GenericLevelSetUnacknowledged(level: level)
        guard let angleModel = node.angleModel else { return }
        _ = try? MeshNetworkManager.instance.send(message, to: angleModel)
    }
    
    func runtimeSet() {
        guard let vendorModel = node.vendorModel else { return }
        let message = GLRunTimeMessage(time: Int(runTime))
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func fadetimeSet() {
        guard let vendorModel = node.vendorModel else { return }
        let message = GLFadeTimeMessage(time: Int(fadeTime))
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
    }
    
    func pirOnOff(onOff: Bool) {
        guard let vendorModel = node.vendorModel else { return }
        Loading.show()
        let status = GLSimpleStatus(bool: onOff)
        let message = GLSensorMessage(status: status)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
        Task {
            try? await Task.sleep(nanoseconds: 6000000000)
            aiOnOff(onOff: onOff)
        }
    }
    
    func aiOnOff(onOff: Bool) {
        guard let vendorModel = node.vendorModel else { return }
        let status = GLSimpleStatus(bool: onOff)
        let message = GLAiMessage(status: status)
        _ = try? MeshNetworkManager.instance.send(message, to: vendorModel)
        Loading.hidden()
    }
}


extension CLightView: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager, didReceiveMessage message: MeshMessage, sentFrom source: Address, to destination: MeshAddress) {
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
        default: break
        }
    }
}

#Preview {
    CLightView(node: MeshNetworkManager.instance.meshNetwork!.nodes.first!, isB: false)
}
