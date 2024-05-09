//
//  BSceneEditView.swift
//  nRF Mesh
//
//  Created by yan on 2024/5/7.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI
import nRFMeshProvision

struct BSceneEditView: View {
    @State private var scene: nRFMeshProvision.Scene?
    @State private var nameText: String = ""
    @State private var describeText: String = ""
    @State private var numberText: String = ""
    private var title: String = ""
    
    init(scene: nRFMeshProvision.Scene? = nil) {
        self.scene = scene
        title = scene == nil ? "New Scene" : "Modifying Scene"
    }
    
    var body: some View {
        VStack(spacing: 10) {
            InputItemView(title: "Name", placehoder: "Scene name", text: $nameText)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            InputItemView(title: "Decribe", placehoder: "Scene description", text: $describeText)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            InputItemView(title: "Number", placehoder: "Scene number", text: $numberText)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
                .frame(height: 50)
            Button(action: {
                
            }, label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.black)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            })
            Button(action: {
                
            }, label: {
                Text("Cancel")
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke()
                    }
            })
            Spacer()
        }
        .padding(20)
        .navigationTitle(title)
        .toolbar {
            TooBarBackItem()
        }
        .background(Color.secondaryBackground)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    BSceneEditView()
        .background(Color.secondaryBackground)
}
