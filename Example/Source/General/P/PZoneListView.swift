//
//  PZoneListView.swift
//  nRF Mesh
//
//  Created by yan on 2024/6/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct PZoneListView: View {
    @EnvironmentObject var appManager: AppManager
    @State var zones: [GLZone] = []
    @State private var isShowSetting = false
    @State var selectedZone: GLZone?
    var body: some View {
        NavigationStack(path: $appManager.p.path) {
            List(zones, id: \.self, selection: $selectedZone) { zone in
                NavigationLink(value: NavPath.pZoneDetail(zone: zone)) {
                    VStack(alignment: .leading, spacing: 13) {
                        Text(zone.name)
                            .font(.labelTitle)
                            .foregroundStyle(Color.accent)
                        Text("Address: 0x\(String(zone.number, radix: 16))")
                            .font(.secondaryLabel)
                            .foregroundColor(Color.secondaryLabel)
                    }
                }
                .listRowSeparator(.hidden)
                .listSectionSpacing(0)
                .listRowBackground(
                    Color.tertiaryBackground
                )
            }
            .listRowSpacing(10)
            .contentMargins(.top, 10)
            .navigationTitle("Zones")
            .toolbar {
                NavigationLink(value: NavPath.pZoneDetail(zone: nil)) {
                    Image(systemName: "plus")
                }
            }
            .onAppear(perform: onAppera)
            .navigationDestination(for: NavPath.self) { target in
                switch target {
                case .pZoneDetail(let zone):
                    PZoneDetailView(zone: zone)
                default: Text("")
                }
            }
        }
    }
}

private extension PZoneListView {
    func onAppera() {
        zones = GLMeshNetworkModel.instance.zones
    }
}

#Preview {
    PZoneListView()
}
