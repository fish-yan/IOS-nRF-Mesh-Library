//
//  CScenesView.swift
//  nRF Mesh
//
//  Created by yan on 2024/3/30.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct CScenesView: View {
    @ObservedObject var zone: GLZone
    @State private var columns = [GridItem(.adaptive(minimum: 170, maximum: 200))]
    
    @State private var scenes: [NordicMesh.Scene] = []
    
    var body: some View {
        ScrollView(.vertical) { 
            VStack(spacing: 10) {
                HStack(spacing: 40) {
                    COnOffItemView(isSelected: zone.store.isOn == false, icon: .icAllOff, title: "All Close") {
                        zone.store.isOn = false
                        onOffSet(onOff: false, group: D000)
                    }
                    Color.accent
                        .frame(width: 1)
                    COnOffItemView(isSelected: zone.store.isOn == true, icon: .icAllOn, title: "Full Open") {
                        zone.store.isOn = true
                        onOffSet(onOff: true, group: D004)
                    }
                }
                .padding(20)
                .background(Color.tertiaryBackground)
                .clipShape(.rect(cornerRadius: 10))
                Text("Scene")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title)
                    .foregroundStyle(Color.accent)
                LazyVGrid(columns: columns) {
                    ForEach(scenes, id: \.self) { model in
                        sceneItem(isSelected: zone.store.selectedScene == model.number, image: model.icon, title: model.name, des: model.detail) {
                            zone.store.selectedScene = model.number
                            sceneRecallSet()
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0))
        }
        .scrollIndicators(.hidden)
        .onAppear(perform: onAppera)
    }
    
    func sceneItem(isSelected: Bool, image: String, title: String, des: String, action: @escaping () -> Void) -> some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(image)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(isSelected ? Color.whiteLabel : Color.accent)
                    Spacer()
                    Image(isSelected ? .icSceneOn : .icSceneOff)
                }
                Spacer()
                    .frame(height: 10)
                Text(title)
                    .font(.labelTitle)
                    .foregroundStyle(isSelected ? Color.whiteLabel : Color.accent)
                Text(des)
                    .font(.secondaryLabel)
                    .foregroundStyle(Color.secondaryLabel)
                    .frame(height: 35, alignment: .topLeading)
            }
            .padding(20)
            .background(isSelected ? Color.accent : Color.tertiaryBackground)
            .clipShape(.rect(cornerRadius: 19))
            .onTapGesture(perform: action)
    }
    
    
    var D000: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD000
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D001: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD001
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D002: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD002
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D003: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD003
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D004: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD004
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D005: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD005
        return try! NordicMesh.Group(name: "", address: address)
    }
    
    var D006: NordicMesh.Group {
        let address = UInt16(zone.zone) * 16 + 0xD006
        return try! NordicMesh.Group(name: "", address: address)
    }
}


extension CScenesView {
    
    func onAppera() {
        scenes = zone.scenes()
        columns = scenes.count <= 2 ? [GridItem()] : [GridItem(.adaptive(minimum: 170, maximum: 200))]
    }
    
    func onOffSet(onOff: Bool, group: NordicMesh.Group) {
        let message = GenericOnOffSet(onOff)
        _ = try? MeshNetworkManager.instance.send(message, to: group)
        MeshNetworkManager.instance.saveModel()
    }

    func sceneRecallSet() {
        let message = SceneRecallUnacknowledged(zone.store.selectedScene)
        _ = try? MeshNetworkManager.instance.send(message, to: D000)
        MeshNetworkManager.instance.saveModel()
    }
    
}


#Preview {
    CScenesView(zone: GLZone(name: "All", zone: 0x0))
}
