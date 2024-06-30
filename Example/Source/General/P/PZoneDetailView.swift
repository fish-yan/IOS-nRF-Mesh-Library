//
//  PZoneDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2024/6/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct PZoneDetailView: View {
    @EnvironmentObject var appManager: AppManager
    @EnvironmentObject var sceneStoreManager: BSceneStoreManager
    
    @State private var nameText: String = ""
    @State private var numberText: String = ""
    
    private var title: String = ""
    @State private var zoneNumber: UInt8 = 0x0
    
    @State private var isDeleteSceneAlert: Bool = false
    
    var zone: GLZone?
    
    init(zone: GLZone? = nil) {
        self.zone = zone
        title = zone == nil ? "New Zone" : "Modifying Zone"
    }
    
    var body: some View {
        VStack(spacing: 10) {
            InputItemView(title: "Name", placehoder: "Zone name", text: $nameText)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            InputItemView(title: "Number", placehoder: "Zone number", text: $numberText)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(true)
            Spacer()
                .frame(height: 50)
            Button(action: saveAction, label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.black.opacity(nameText.isEmpty ? 0.3 : 1))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            })
            .disabled(nameText.isEmpty)
            if zone?.number != 0 {
                Button(action: {
                    hideKeyboard()
                    if let zone {
                        if !zone.nodeAddresses.isEmpty {
                            isDeleteSceneAlert = true
                        } else {
                            GLMeshNetworkModel.instance.remove(zone)
                            MeshNetworkManager.instance.saveAll()
                            appManager.p.path.removeLast()
                        }
                    } else {
                        appManager.p.path.removeLast()
                    }
                }, label: {
                    Text(zone == nil ? "Cancel" : "Delete")
                        .foregroundStyle(zone == nil ? .black : .red)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke()
                        }
                })
            }
            Spacer()
        }
        .padding(20)
        .navigationTitle(title)
        .background(Color.secondaryBackground)
        .ignoresSafeArea(.keyboard)
        .alert("Warning", isPresented: $isDeleteSceneAlert, actions: {
            Button("Cancel", role: .cancel, action: {})
            Button(role: .destructive) {
                if let zone {
                    GLMeshNetworkModel.instance.remove(zone)
                    MeshNetworkManager.instance.saveAll()
                    appManager.p.path.removeLast()
                }
            } label: {
                Text("Delete")
            }
        }, message: {
            Text("This scene is in use, delete or not?")
        })
        .onAppear(perform: onAppear)
        .loadingable()
    }
}

private extension PZoneDetailView {
    func onAppear() {
        if let zone {
            nameText = zone.name
            numberText = "0x" + String(zone.number, radix: 16)
        } else {
            zoneNumber = GLMeshNetworkModel.instance.nextZone()
            numberText = "0x" + String(zoneNumber, radix: 16)
        }
    }
    
    func saveAction() {
        hideKeyboard()
        if let zone {
            zone.name = nameText
        } else {
            let zone = GLZone(name: nameText, number: zoneNumber)
            GLMeshNetworkModel.instance.add(zone)
        }
        MeshNetworkManager.instance.saveAll()
        appManager.p.path.removeLast()
    }
}

#Preview {
    PZoneDetailView()
}
