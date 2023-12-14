//
//  ZoneListView.swift
//  nRF Mesh
//
//  Created by yan on 2023/12/7.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct ZoneListView: View {
    @State var zones: [GLZone] = []
    @State var isShowAdvance = false
    var body: some View {
        NavigationView {
            List {
                ForEach(zones, id: \.self) { zone in
                    NavigationLink {
                        GroupControlView(zone: zone)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(zone.name)
                            Text("Address: 0x\(String(zone.zone, radix: 16))")
                                .font(.subheadline)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                        }
                    }
                }
                .onDelete(perform: delete)
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
