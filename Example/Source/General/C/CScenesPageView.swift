//
//  CScenesPageView.swift
//  nRF Mesh
//
//  Created by yan on 2024/3/30.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

private class CScenesPageStore: ObservableObject {
    @Published var selectedIndex = 0
}

struct CScenesPageView: View {
    @EnvironmentObject var appManager: AppManager
    @ObservedObject private var store = CScenesPageStore()
    @State private var zones: [GLZone] = []
    
    var body: some View {
        VStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("hi,lynn")
                        .font(.secondaryLabel)
                        .foregroundStyle(Color.secondaryLabel)
                    Spacer()
                    Button {
                        appManager.userRole = .supervisor
                    } label: {
                        Image(.icSetting)
                    }
                }
                Text("Welcome")
                    .font(.title)
                    .foregroundStyle(Color.primary)
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
            let segments = zones.map { $0.name }
            MeshSegmentView(segments: segments, selectedSegment: $store.selectedIndex)
            TabView(selection: $store.selectedIndex) {
                ForEach(zones.indices, id: \.self) { index in
                    CScenesView(zone: zones[index])
                        .tag(index)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: store.selectedIndex)
        }
        .onAppear(perform: onAppera)
    }
}

private extension CScenesPageView {
    func onAppera() {
        zones = GLMeshNetworkModel.instance.zones.filter({!$0.nodeAddresses.isEmpty})
    }
}

#Preview {
    CScenesPageView()
        .background(Color(UIColor.systemGroupedBackground))
}
