//
//  GroupsManagerView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct GroupsManagerView: View {
    @State private var groups: [nRFMeshProvision.Group] = []
    @State private var addDone: Bool = false
    var body: some View {
        List {
            ForEach(groups, id: \.address) { group in
                NavigationLink(destination: GroupElementManagerView(group: group)) {
                    ItemView(resource: .meshGroup, title: group.name, detail: "Address: 0x\(group.address.hex)")
                }
            }
            .onDelete(perform: delete)
            
        }
        .navigationTitle("Groups Manager")
        .toolbar { addItem }
        .onAppear {
            groups = MeshNetworkManager.instance.meshNetwork?.groups ?? []
        }
    }
    
    var addItem: some View {
        NavigationLink {
            AddGroupView(isDone: $addDone)
                .navigationTitle("Add Group")
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
        let group = groups[index]
        
        groups.remove(atOffsets: indexSet)
        
        try? MeshNetworkManager.instance.meshNetwork?.remove(group: group)
        let _ = MeshNetworkManager.instance.save()
    }
}

struct AddGroupView: UIViewControllerRepresentable {
    @Binding var isDone: Bool
    var group: nRFMeshProvision.Group? = nil
    func makeUIViewController(context: Context) -> AddGroupViewController {
        let addGroupVc = UIStoryboard(name: "Groups", bundle: nil).instantiateViewController(identifier: "AddGroupViewController") as! AddGroupViewController
        addGroupVc.view.frame = UIScreen.main.bounds
        if let group {
            addGroupVc.group = group
        }
        return addGroupVc
    }
    
    func updateUIViewController(_ uiViewController: AddGroupViewController, context: Context) {
        isDone ? uiViewController.doneSave() : ()
        isDone = false
    }
    
    typealias UIViewControllerType = AddGroupViewController
}
