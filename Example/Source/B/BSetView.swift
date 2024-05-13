//
//  BSetView.swift
//  nRF Mesh
//
//  Created by yan on 2024/5/6.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct BSetView: View {
    @EnvironmentObject var appManager: AppManager
    @State private var index = 0
    @State private var proxy: ScrollViewProxy?

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
            HStack(spacing: 0) {
                item(text: "Lights", tag: 0, proxy: proxy)
                item(text: "Zones", tag: 1, proxy: proxy)
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            
                ScrollView(.horizontal) {
                    HStack {
                        BLightListView()
                            .frame(width: UIScreen.main.bounds.width)
                            .id(0)
                        BZoneListView()
                            .frame(width: UIScreen.main.bounds.width)
                            .id(1)
                    }
                }
                .scrollIndicators(.hidden)
                .scrollDisabled(true)
            }
        }
        .navigationTitle("Scene settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                appManager.userRole = .commissioner
            } label: {
                Image(.icSetting)
            }
        }
        .navigationDestination(for: NavPath.self) { target in
            switch target {
            case .bZoneView(let zone):
                BZoneView(zone: zone)
            case .bSceneStoreZoneView(let zone):
                BSceneStoreView(zone: zone)
            case .cLightView(let node):
                CLightView(node: node, isB: true)
            case .bSceneStoreNodeView(let node):
                BSceneStoreView(node: node)
            default: Text("")
            }
        }
    }
    
    func item(text: String, tag: Int, proxy: ScrollViewProxy) -> some View {
        Text(text)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(index == tag ? .black : .white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .foregroundStyle(index == tag ? .white : .black)
            .onTapGesture { 
                index = tag
                proxy.scrollTo(tag)
            }
    }
}

#Preview {
    BSetView()
}
