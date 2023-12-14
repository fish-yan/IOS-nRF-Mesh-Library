//
//  SceneDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/9.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct SceneDetailView: View {
    var title = "Scene"
    @State private var isOn = false
    @State private var isSensorOn = false
    @State private var isAIOn = false
    @State private var level: Double = 0
    var body: some View {
        List {
            Section {
                Button {
                    isOn.toggle()
                } label: {
                    Image(systemName: "power.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .tint(isOn ? .orange : .gray.opacity(0.5))
                        .background(.clear)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            } header: {
                Text("power")
            }
            .buttonStyle(.borderless)
            
            Section {
                Toggle("Sensor", isOn: $isSensorOn)
                Toggle("AI", isOn: $isAIOn)
            } header: {
                Text("control")
            }
        }
        .navigationTitle(title)
    }
}
