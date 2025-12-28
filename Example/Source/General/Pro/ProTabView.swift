//
//  ProTabView.swift
//  nRF Mesh
//
//  Created by yan on 2025-12-27.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI

struct ProTabView: View {
    @EnvironmentObject var appManager: AppManager
    var body: some View {
        TabView(selection: $appManager.pro.selectedTab) {
            ProLightListView()
                .tag(0)
                .background(Color.groupedBackground)
                .tabItem {
                    Label("灯具", image: appManager.pro.selectedTab == 0 ? .icTabLightsSelected : .icTabLightsNormal)
                        .tint(appManager.pro.selectedTab == 0 ? .primary : .secondary)
                }
            ProSettingView()
                .tag(1)
                .background(Color.groupedBackground)
                .tabItem {
                    Label("设置", image: .ipTabSetting)
                        .tint(appManager.pro.selectedTab == 1 ? .primary : .secondary)
                }
        }
        .background(Color.groupedBackground)
    }
}

#Preview {
    ProTabView()
}
