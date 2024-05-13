//
//  ZoneListView.swift
//  nRF Mesh
//
//  Created by yan on 2023/12/7.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct ZoneListView: View {
    @State var zones: [GLZone] = []
    @State var isShowAdvance = false
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(zones, id: \.self) { zone in
                        NavigationLink {
                            GroupControlView(zone: zone)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(zone.name)
                                    .font(.headline)
                                Text("Address: 0x\(String(zone.zone, radix: 16))")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                            }
                            .background()
                        }
                    }
                    .onDelete(perform: delete)
                } footer: {
                    Text("")
                }
            }
            .navigationTitle("Zone")
            .toolbar {
                NavigationLink {
                    AddZoneView()
                } label: {
                    Image(systemName: "plus")
                }
                .opacity(isShowAdvance ? 1 : 0)
            }
            .onAppear {
                isShowAdvance = GlobalConfig.isShowAdvance
                zones = GLMeshNetworkModel.instance.zone
            }
        }
    }
    
    func delete(indexSet: IndexSet) {
        GLMeshNetworkModel.instance.zone.remove(atOffsets: indexSet)
        MeshNetworkManager.instance.saveModel()
    }
}
