//
//  LightSelectedView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/24.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import NordicMesh

struct LightSelectedView: View {
    
    @Environment(\.dismiss) var dismiss
        
    @State var multiSelected: Set<Node> = []
    
    var originSelected: Set<Node> = []
    
    @State private var editMode: EditMode = .active
    
    var doneCallback: (((add: Set<Node>, delete: Set<Node>)) -> Void)?
    
    var allNodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner }
    
//    init(multiSelected: Set<Node>, doneCallback: (((add: Set<Node>, delete: Set<Node>)) -> Void)?) {
//        self.originSelected = multiSelected
//        self.multiSelected = multiSelected
//        self.doneCallback = doneCallback
//    }
//    
    var body: some View {
        List(allNodes, id: \.self, selection: $multiSelected) { node in
            VStack(alignment: .leading) {
                Text(node.name ?? "Unknow")
                    .font(.headline)
                Text("Address: 0x\(node.primaryUnicastAddress.hex)")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
        }
        .navigationTitle("Select Lights")
        .toolbar {
            Button(action: doneAction) {
                Text("Done")
            }
        }
        .environment(\.editMode, $editMode)
    }
}

extension LightSelectedView {
    func doneAction() {
        let delete = originSelected.subtracting(multiSelected)
        let add = multiSelected.subtracting(originSelected)
        doneCallback?((add: add, delete: delete))
        dismiss.callAsFunction()
    }
}

extension Node: Identifiable, Hashable {
    public var id: UUID { UUID() }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(primaryUnicastAddress)
    }
}

