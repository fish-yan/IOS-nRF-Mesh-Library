//
//  ScenesManagerView.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/9.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct ScenesManagerView: View {
    @State private var scenes = MeshNetworkManager.instance.meshNetwork?.scenes ?? []
    @State private var addDone: Bool = false
    var body: some View {
        List {
            ForEach(scenes, id: \.number) { scene in
                NavigationLink {
                    SceneLightsView(scene: scene)
                } label: {
                    ItemView(resource: .groupSceneOutline, title: scene.name, detail: "Number: \(scene.number)")
                }
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Scenes Manager")
        .toolbar { addItem }
        .onAppear(perform: {
            scenes = MeshNetworkManager.instance.meshNetwork?.scenes ?? []
        })
    }
    
    var addItem: some View {
        NavigationLink {
            AddSceneView(isDone: $addDone)
                .navigationTitle("Add Scene")
                .toolbar {
                    Button("Done") {
                        addDone = true
                    }
                }
                
        } label: {
            Image(systemName: "plus")
        }
    }
    
    func delete(indexSet: IndexSet) {
        guard let index = indexSet.min() else {
            return
        }
        let scene = scenes[index]
        scenes.remove(atOffsets: indexSet)
        try? MeshNetworkManager.instance.meshNetwork?.remove(scene: scene.number)
        let _ = MeshNetworkManager.instance.save()
    }
}

struct AddSceneView: UIViewControllerRepresentable {
    @Binding var isDone: Bool
    var scene: nRFMeshProvision.Scene?
    func makeUIViewController(context: Context) -> EditSceneViewController {
        let addSceneVc = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(identifier: "EditSceneViewController") as! EditSceneViewController
        addSceneVc.view.frame = UIScreen.main.bounds
        if let scene {
            addSceneVc.scene = scene
        }
        return addSceneVc
    }
    
    func updateUIViewController(_ uiViewController: EditSceneViewController, context: Context) {
        isDone ? uiViewController.doneSave() : ()
        isDone = false
    }
    
    typealias UIViewControllerType = EditSceneViewController
    
    
}

#Preview {
    ScenesManagerView()
}
