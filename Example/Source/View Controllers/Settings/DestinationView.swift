//
//  DestinationView.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct DestinationView: View {
    
    let messages: [GLMessageModel]

    var body: some View {
        List {
            Section {
                NavigationLink("Lights", destination: LightsSendView(messages: messages))
            }
            
            Section {
                NavigationLink("Groups", destination: GroupsSendView(messages: messages))
            }
        }
        .navigationTitle("Destination")
    }
}
