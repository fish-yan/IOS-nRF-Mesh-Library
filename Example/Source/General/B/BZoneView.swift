//
//  BZoneView.swift
//  nRF Mesh
//
//  Created by yan on 2024/5/8.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct BZoneView: View {
    
    @State private var isOn: Bool?
    @State private var dim: Double = 1
    @State private var cct: Double = 0.5
    @State private var angle: Double = 0.5
    @State private var runTime: Double = 0
    @State private var fadeTime: Double = 0
    @State private var isDynamicMode: Bool?
    @State private var sliderType: MeshSliderType = .dim
    @State private var selection: Int = 0
    @State private var isPresented = false
    @State private var levels: [Int] = [100, 70, 50, 20]
        
    let zone: GLZone
    var body: some View {
        VStack {
            dynamicModelView
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment:.leading, spacing: 0) {
                    Text("Mode Parameters")
                        .font(.section)
                    Text("Drag to adjust the parameters of the light")
                        .font(.secondaryLabel)
                        .foregroundStyle(.secondaryLabel)
                }
                
                switch sliderType {
                case .dim:
                    MeshSliderView(value: $dim, type: sliderType) {
                        levelSet(value: dim, group: D000)
                    }
                case .cct:
                    MeshSliderView(value: $cct, type: sliderType) {
                        levelSet(value: cct, group: D001)
                    }
                case .angle:
                    MeshSliderView(value: $angle, type: sliderType) {
                        levelSet(value: angle, group: D002)
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
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 20)
                .fill(Color.white).ignoresSafeArea())
            Spacer()
        }
        .padding(20)
        .background(Color.groupedBackground.ignoresSafeArea())
        .sheet(isPresented: $isPresented) {
            LevelPickerView(onCanceled: {
                isPresented = false
            }, onConfirmed: { value in
                isPresented = false
                levels = value
                glLevelsSet()
            })
            .presentationDetents([.height(275)])
        }
        .navigationTitle("Zone")
        .toolbar {
            TooBarBackItem()
        }
        .toolbar {
            NavigationLink(value: NavPath.bSceneStoreZoneView(zone: zone)) {
                Text("Save")
                    .underline()
                    .font(.label)
            }
        }
        .navigationBarBackButtonHidden(true)
        .loadingable()
    }
    
    var dynamicModelView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                HStack(spacing: 20) {
                    COnOffItemView(isSelected: isDynamicMode == false, icon: .ibDynamicOff, title: "OFF") {
                        withAnimation {
                            isDynamicMode = false
                        }
                        pirOnOff(onOff: false)
                    }
                    Text("Dynamic mode")
                        .font(.label)
                        .frame(width: 130)
                    COnOffItemView(isSelected: isDynamicMode == true, icon: .ibDynamicOn, title: "ON") {
                        withAnimation {
                            isDynamicMode = true
                        }
                        pirOnOff(onOff: true)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            if isDynamicMode != false {
                Divider()
                HStack {
                    Text("Level")
                        .font(.secondaryLabel)
                    Spacer()
                    Button {
                        isPresented = true
                    } label: {
                        let levelStr = levels.map({"\($0)%"}).joined(separator: " ")
                        HStack {
                            Text(levelStr)
                                .foregroundStyle(Color.secondary)
                            Image(systemName: "chevron.right")
                        }
                    }
                    .font(.secondaryLabel)
                }
                Divider()
                VStack(spacing: 10) {
                    sliderView(title: "Run time", value: $runTime, in: 0...900) {_ in
                        runtimeSet()
                    }
                    sliderView(title: "Fade time", value: $fadeTime, in: 0...60) {_ in
                        fadetimeSet()
                    }
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20)
            .fill(Color.white).ignoresSafeArea())
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
                .font(.secondaryLabel)
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
    
    var D000: NordicMesh.Group {
        let address = UInt16(zone.number) * 16 + 0xD000
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D001: NordicMesh.Group {
        let address = UInt16(zone.number) * 16 + 0xD001
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D002: NordicMesh.Group {
        let address = UInt16(zone.number) * 16 + 0xD002
        return try! NordicMesh.Group(name: "", address: address)
    }
}

private extension BZoneView {
    
    func pirOnOff(onOff: Bool) {
        Loading.show()
        let status = GLSimpleStatus(bool: onOff)
        let message = GLSensorMessage(status: status)
        _ = try? MeshNetworkManager.instance.send(message, to: D000)
        Task {
            try? await Task.sleep(nanoseconds: 6000000000)
            aiOnOff(onOff: onOff)
        }
    }
    
    func aiOnOff(onOff: Bool) {
        let status = GLSimpleStatus(bool: onOff)
        let message = GLAiMessage(status: status)
        _ = try? MeshNetworkManager.instance.send(message, to: D000)
        Loading.hidden()
    }
    
    func levelSet(value: Double, group: NordicMesh.Group) {
        let level = Int16(min(32767, -32768 + 65536 * value)) // -32768...32767
        let message = GenericLevelSetUnacknowledged(level: level)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
    }
    
    func glLevelsSet() {
        let levels = self.levels.map({UInt8($0)})
        let message = GLLevelMessage(levels: levels)
        _ = try? MeshNetworkManager.instance.send(message, to: D000)
    }
    
    func runtimeSet() {
        let message = GLRunTimeMessage(time: Int(runTime))
        _ = try? MeshNetworkManager.instance.send(message, to: D000)
    }
    
    func fadetimeSet() {
        let message = GLFadeTimeMessage(time: Int(fadeTime))
        _ = try? MeshNetworkManager.instance.send(message, to: D000)
    }
}


#Preview {
    BZoneView(zone: GLMeshNetworkModel.instance.zones.first!)
}
