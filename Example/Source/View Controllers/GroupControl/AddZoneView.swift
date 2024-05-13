//
//  AddZone.swift
//  nRF Mesh
//
//  Created by yan on 2023/12/7.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct AddZoneView: View {
    @Environment(\.dismiss) var dismiss
    @State var name: String = "Zone"
    @State var zone: String = ""
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("input name", text: $name)
                        .frame(width: 100)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Zone")
                    Spacer()
                    TextField("input zone", text: $zone)
                        .frame(width: 100)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .navigationTitle("Add Zone")
        .toolbar {
            Button("Save", action: save)
        }
        .onAppear {
            zone = "0x" + String(GLMeshNetworkModel.instance.nextZone(), radix: 16)
        }
    }
}

extension AddZoneView {
    func save() {
        let value = zone.replacingOccurrences(of: "0x", with: "")
        if let z = UInt8(value, radix: 16),
           !name.isEmpty {
            let zone = GLZone(name: name, zone: z)
            GLMeshNetworkModel.instance.zone.append(zone)
            MeshNetworkManager.instance.saveModel()
        }
        dismiss.callAsFunction()
    }
}
