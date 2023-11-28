//
//  SettingsView.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/11.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct SettingsView1: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    SettingsView()
                } label: {
                    itemView(title: "User Setting", image: "gear", color: .gray)
                }
                NavigationLink {
                    
                } label: {
                    itemView(title: "About Us", image: "bookmark", color: .orange)
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func itemView(title: String, image: String, color: Color) -> some View {
        HStack {
            Image(systemName: image)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(color)
                .cornerRadius(6)
                .clipped()
            Spacer().frame(width: 16)
            Text(title)
        }
    }
}

#Preview {
    SettingsView()
}
