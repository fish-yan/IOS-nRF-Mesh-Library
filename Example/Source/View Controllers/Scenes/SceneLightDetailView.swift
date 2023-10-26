//
//  SceneLightDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct SceneLightDetailView: View {
    @Environment(\.dismiss) var dismiss
    var node: Node
    private var onOffModel: Model?
    private var levelModel: Model?
    private var CCTModel: Model?
    private var angleModel: Model?
    
    @ObservedObject var store = LightDetailStore()

    private var messageManager = MeshMessageManager()
    
    init(node: Node) {
        
        self.node = node
        let models = node.primaryElement?.models ?? []
        onOffModel = models.first(where: {$0.modelIdentifier == .genericOnOffServerModelId})
        levelModel = models.first(where: {$0.modelIdentifier == .genericLevelServerModelId})
        CCTModel = models.first(where: {$0.modelIdentifier == .genericLevelServerModelId})
        angleModel = models.first(where: {$0.modelIdentifier == .genericLevelServerModelId})
        
//        messageManager.delegate = self
    }
    
    var body: some View {
        List {
            Section {
                Button {
                    store.isOn.toggle()
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
                    
                }
                
                SliderView(value: $store.CCT, title: "CCT") { isEditing in
                    
                }
                
                SliderView(value: $store.angle, title: "Angle") { isEditing in
                    
                }
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle(node.name ?? "Unknow")
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
