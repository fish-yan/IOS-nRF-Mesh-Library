//
//  CLightListView.swift
//  test
//
//  Created by yan on 2024/3/30.
//

import SwiftUI
import nRFMeshProvision

struct BZoneListView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State var zones: [GLZone] = []
    @State private var isShowSetting = false
    @State var selectedZone: GLZone?
    var body: some View {
        List(zones, id: \.self, selection: $selectedZone) { zone in
            NavigationLink(value: NavPath.bZoneView(zone: zone)) {
                VStack(alignment: .leading, spacing: 13) {
                    Text(zone.name)
                        .font(.label)
                        .foregroundStyle(Color.accent)
                    Text("Address: 0x\(String(zone.zone, radix: 16))")
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
        .onAppear(perform: onAppera)
        .navigationDestination(for: NavPath.self) { target in
            switch target {
            case .cLightView(let node):
                CLightView(node: node)
            default: Text("")
            }
        }
    }
}

private extension BZoneListView {
    func onAppera() {
        zones = GLMeshNetworkModel.instance.zone
        //        selectedNode = nodes.first
    }
}

#Preview {
    BZoneListView()
}
