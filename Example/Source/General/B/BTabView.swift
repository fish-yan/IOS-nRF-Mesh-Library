//
//  MeshTabView.swift
//  nRF Mesh
//
//  Created by yan on 2024/4/1.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct BTabView: View {
    @EnvironmentObject var appManager: AppManager
    var body: some View {
            TabView(selection: $appManager.b.selectedTab) {
                BScenesView()
                    .tag(0)
                    .background(Color.groupedBackground)
                    .tabItem {
                        Label("Main", image: appManager.b.selectedTab == 0 ? .icTabMainSelected : .icTabMainNormal)
                    }
                BSetView()
                    .tag(1)
                    .background(Color.groupedBackground)
                    .tabItem {
                        Label("Lights", image: appManager.b.selectedTab == 1 ? .icTabLightsSelected : .icTabLightsNormal)
                    }
            }
            .background(Color.groupedBackground)
    }
}

#Preview {
    BTabView()
}
