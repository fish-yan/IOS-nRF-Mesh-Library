//
//  MeshTabView.swift
//  nRF Mesh
//
//  Created by yan on 2024/4/1.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import Combine

struct CTabView: View {
    @EnvironmentObject var appManager: AppManager
    var body: some View {
        TabView(selection: $appManager.c.selectedTab) {
            CScenesPageView()
                .tag(0)
                .background(Color.groupedBackground)
                .tabItem {
                    Label("Main", image: appManager.c.selectedTab == 0 ? .icTabMainSelected : .icTabMainNormal)
                }
            CLightListView()
                .tag(1)
                .background(Color.groupedBackground)
                .tabItem {
                    Label("Lights", image: appManager.c.selectedTab == 1 ? .icTabLightsSelected : .icTabLightsNormal)
                }
        }
        .background(Color.groupedBackground)
    }
}

#Preview {
    CTabView()
}
