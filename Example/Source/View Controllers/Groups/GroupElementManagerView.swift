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
        List(ElementType.allCases, id: \.self) { type in
            ElementView(type: type)
            
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
    
    
}

struct ElementView: View {
    @State private var isActive: Bool = false
    var type: ElementType
    var body: some View {
        NavigationLink(destination: LightSelectedView(isPushed: $isActive), isActive: $isActive) {
            HStack {
                Image(systemName: type.image)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(type.color)
                    .cornerRadius(6)
                    .clipped()
                Spacer().frame(width: 16)
                Text(type.title)
            }
        }
    }
}
 
enum ElementType: CaseIterable {
    case onOff, level, cct, angle
    
    var image: String {
        switch self {
        case .onOff: "power.circle.fill"
        case .level: "sun.max.fill"
        case .cct: "lightbulb.led.fill"
        case .angle: "light.overhead.right.fill"
        }
    }
    var title: String {
        switch self {
        case .onOff: "On/Off"
        case .level: "Level"
        case .cct: "CCT"
        case .angle: "Beam Angle"
        }
    }
    
    var color: Color {
        switch self {
        case .onOff: .orange
        case .level: .blue
        case .cct: .yellow
        case .angle: .gray
        }
    }
}
