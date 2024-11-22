//
//  SetAnglesView.swift
//  nRF Mesh
//
//  Created by yan on 1/11/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct AnglesConfigurationView: View {
    @State var data = AppManager.manager.anglePercents.map({"\($0)"})
    var body: some View {
        List {
            ForEach(data.indices, id: \.self) { index in
                HStack {
                    Text("\(AppManager.manager.angles[index])°")
                        .font(.headline)
                    Spacer()
                    TextField("level", text: Binding<String>(get: {
                        return data[index]
                    }, set: { text in
                        data[index] = text
                    }))
                    .frame(width: 100)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                }
            }
        }
        .navigationTitle("Angles Configuration")
        .onDisappear {
            AppManager.manager.anglePercents = data.compactMap({Double($0)}).sorted()
        }
    }
}

#Preview {
    AnglesConfigurationView()
}
