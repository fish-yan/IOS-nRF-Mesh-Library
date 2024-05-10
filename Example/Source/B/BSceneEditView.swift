//
//  BSceneEditView.swift
//  nRF Mesh
//
//  Created by yan on 2024/5/7.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct BSceneEditView: View {
    @EnvironmentObject var pathManager: BPathManager
    @EnvironmentObject var sceneStoreManager: BSceneStoreManager
    
    private let scene: nRFMeshProvision.Scene?
    @State private var nameText: String = ""
    @State private var describeText: String = "Personalised Lighting Modes"
    @State private var numberText: String = ""
    
    private var title: String = ""
    @State private var sceneNumber: SceneNumber = 0x0
    
    @State private var isPresented: Bool = false
    @State private var isDeleteSceneAlert: Bool = false
    
    init(scene: nRFMeshProvision.Scene? = nil) {
        self.scene = scene
        title = scene == nil ? "New Scene" : "Modifying Scene"
    }
    
    var body: some View {
        VStack(spacing: 10) {
            InputItemView(title: "Name", placehoder: "Scene name", text: $nameText)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            InputItemView(title: "Decribe", placehoder: "Scene description", text: $describeText)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            InputItemView(title: "Number", placehoder: "Scene number", text: $numberText)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(true)
            Spacer()
                .frame(height: 50)
            Button(action: {
                let meshNetwork = MeshNetworkManager.instance.meshNetwork!
                if let scene {
                    scene.name = nameText
                    scene.detail = describeText
                } else {
                    try? meshNetwork.add(scene: sceneNumber, name: nameText, detail: describeText)
                }
                MeshNetworkManager.instance.saveAll()
                isPresented = true
            }, label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            })
            Button(action: {
                if let scene {
                    if scene.isUsed {
                        isDeleteSceneAlert = true
                    } else {
                        MeshNetworkManager.instance.meshNetwork?.forceRemove(scene: scene.number)
                        MeshNetworkManager.instance.saveAll()
                        pathManager.path.removeLast()
                    }
                } else {
                    pathManager.path.removeLast()
                }
            }, label: {
                Text(scene == nil ? "Cancel" : "Delete")
                    .foregroundStyle(scene == nil ? .black : .red)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke()
                    }
            })
            Spacer()
        }
        .padding(20)
        .navigationTitle(title)
        .toolbar {
            TooBarBackItem(title: "Scenes")
        }
        .background(Color.secondaryBackground)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard)
        .alert(isPresented: $isPresented) {
            Alert(title: Text("Remind"),
                  message: Text("Select light or zone to continue setting the scene?"),
                  primaryButton: .default(Text("Continue")) {
                pathManager.path.removeAll()
                pathManager.selectedTab = 1
            }, secondaryButton: .cancel() {
                pathManager.path.removeLast()
            })
        }
        .alert(isPresented: $isDeleteSceneAlert) {
            Alert(title: Text("Warning"),
                  message: Text("This scene is in use, delete or not?"),
                  primaryButton: .destructive(Text("Delete")) {
                if let scene {
                    MeshNetworkManager.instance.meshNetwork?.forceRemove(scene: scene.number)
                    MeshNetworkManager.instance.saveAll()
                }
                pathManager.path.removeLast()
            }, secondaryButton: .cancel())
        }
        .onAppear(perform: onAppear)
    }
}

private extension BSceneEditView {
    func onAppear() {
        if let scene {
            nameText = scene.name
            describeText = scene.detail
            numberText = "0x" + String(scene.number, radix: 16)
        } else {
            sceneNumber = MeshNetworkManager.instance.meshNetwork?.nextAvailableScene() ?? 0
            numberText = "0x" + String(sceneNumber, radix: 16)
        }
    }
}

#Preview {
    BSceneEditView()
        .background(Color.secondaryBackground)
}
