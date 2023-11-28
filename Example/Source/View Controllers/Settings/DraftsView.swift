//
//  DraftsView.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/27.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct DraftsView: View {
    var body: some View {
        List {
            ForEach(GLMeshNetworkModel.instance.drafts, id: \.self) { draft in
                NavigationLink {
                    DraftControlView(store: draft.store)
                } label: {
                    VStack(alignment: .leading) {
                        Text(draft.name)
                            .font(.headline)
                            .foregroundStyle(Color(uiColor: .label))
                        Text(draft.store.description)
                            .font(.subheadline)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
                }
                
            }
            .onDelete(perform: onDelete)
        }
        .navigationTitle("Drafts")
    }
    
    func onDelete(indexSet: IndexSet) {
        GLMeshNetworkModel.instance.drafts.remove(atOffsets: indexSet)
        MeshNetworkManager.instance.saveModel()
    }
}

#Preview {
    DraftsView()
}
