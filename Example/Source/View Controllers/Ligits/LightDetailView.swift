//
//  LightDetailView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/21.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct LightDetailView: View {

    @State private var isOn = false
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
            
            Section {
                SliderView(value: 0.1, title: "亮度调节")
                
                SliderView(value: 30, title: "色温调节")
            } header: {
                Text("control")
            }
            
            Section {
                DirectionControlView { direction in
                    print(direction)
                }
            } header: {
                Text("direction")
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle("Light")
    }
}

#Preview {
    LightDetailView()
}
