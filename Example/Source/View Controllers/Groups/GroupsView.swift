//
//  GroupsView.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/12.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct GroupsView: View {
    @State private var groups: [nRFMeshProvision.Group] = []
    @State private var addDone: Bool = false
    @State private var isShowSetting = false
    var body: some View {
        NavigationView {
            List {
                ForEach(groups, id: \.address) { group in
                    NavigationLink(destination: GroupDetailView(group: group)) {
                        ItemView(resource: .meshGroup, title: group.name, detail: "Address: 0x\(group.address.hex)")
                    }
                }
            }
            .navigationTitle("Groups")
            .toolbar {
                NavigationLink(destination: GroupsManagerView()) {
                    Image(systemName: "gearshape")
                }
                .opacity(isShowSetting ? 1 : 0)
            }
            .onAppear {
                groups = MeshNetworkManager.instance.meshNetwork?.customGroups ?? []
                isShowSetting = GlobalConfig.isShowSetting
            }
        }
    }
}
