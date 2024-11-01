//
//  SetAnglesView.swift
//  nRF Mesh
//
//  Created by yan on 1/11/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct AnglesConfigurationView: View {
    @State var data = AppManager.manager.angleConfigs.map({"\($0)"})
    var body: some View {
        List {
            ForEach(data.indices, id: \.self) { index in
                HStack {
                    Text("Level \(index + 1)")
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
                .swipeActions(allowsFullSwipe: false) {
                    Button {
                        data.remove(at: index)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(data.count <= 2 ? .gray : .red)
                    .disabled(data.count <= 2)
                }
            }
        }
        .navigationTitle("Angles Configuration")
        .toolbar {
            Button("", systemImage: "plus") {
                let last = data.last ?? ""
                data.append(last)
            }
        }
        .onDisappear {
            AppManager.manager.angleConfigs = data.compactMap({Double($0)}).sorted()
        }
    }
}

#Preview {
    AnglesConfigurationView()
}
