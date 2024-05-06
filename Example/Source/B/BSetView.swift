//
//  BSetView.swift
//  nRF Mesh
//
//  Created by yan on 2024/5/6.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct BSetView: View {
    @State private var index = 0
    @State private var isPresented = false
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                item(text: "Lights", tag: 0)
                item(text: "Zones", tag: 1)
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            if index == 0 {
                BLightListView()
            } else {
                BZoneListView()
            }
        }
        .navigationTitle("Scene settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                isPresented = true
            } label: {
                Image(.icSetting)
            }
        }
        .fullScreenCover(isPresented: $isPresented, content: {
            RootView()
                .ignoresSafeArea()
        })
    }
    
    func item(text: String, tag: Int) -> some View {
        Text(text)
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(index == tag ? .black : .white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .foregroundStyle(index == tag ? .white : .black)
            .onTapGesture { index = tag }
    }
}

#Preview {
    BSetView()
}
