//
//  GroupElementManagerView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/24.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct GroupElementManagerView: View {
    var group: nRFMeshProvision.Group
    @State var isDone = false
    var body: some View {
        List {
            item("On/Off", imageName: "power", destination: LightSelectedView(), backgroundColor: .orange)
            item("Level", imageName: "sun.max", destination: LightSelectedView(), backgroundColor: .blue)
            item("CCT", imageName: "lightbulb", destination: LightSelectedView(), backgroundColor: .yellow)
            item("Beam Angle", imageName: "light.overhead.right", destination: LightSelectedView(), backgroundColor: .gray)
        }
        .navigationTitle(group.name)
        .toolbar {
            NavigationLink { 
                AddGroupView(isDone: $isDone, group: group)
                    .navigationTitle("Edit Group")
            } label: {
                Image(systemName: "pencil.line")
            }
        }
    }
    
    private func item(_ title: String, imageName: String, destination: some View, backgroundColor: Color) -> NavigationLink<some View, some View> {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(backgroundColor)
                    .cornerRadius(6)
                    .clipped()
                Spacer().frame(width: 16)
                Text(title)
            }
        }
    }
}
