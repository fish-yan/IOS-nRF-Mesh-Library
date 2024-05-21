//
//  PickerView.swift
//  nRF Mesh
//
//  Created by yan on 2024/5/9.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct LevelPickerView: View {
    @State var level0 = 100
    @State var level1 = 70
    @State var level2 = 50
    @State var level3 = 20
    var onCanceled: (() -> Void)?
    var onConfirmed: (([Int]) -> Void)?
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    onCanceled?()
                }
                .font(.label)
                .frame(width: 50)
                Text("Select Levels")
                    .font(.labelTitle)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    
                Button("OK") {
                    onConfirmed?([level0, level1, level2, level3])
                }
                .font(.labelTitle)
                .frame(width: 50)
            }
            .padding()
            .padding(.top, 10)
            Divider()
            HStack(spacing: 0) {
                let data = (0...20).map({$0 * 5})
                Picker("Level", selection: $level0) {
                    ForEach(data, id: \.self) { i in
                        Text("\(i)")
                            .font(.secondaryLabel)
                    }
                }
                .pickerStyle(.wheel)
                Picker("Level", selection: $level1) {
                    ForEach(data, id: \.self) { i in
                        Text("\(i)")
                            .font(.secondaryLabel)
                    }
                }
                .pickerStyle(.wheel)
                Picker("Level", selection: $level2) {
                    ForEach(data, id: \.self) { i in
                        Text("\(i)")
                            .font(.secondaryLabel)
                    }
                }
                .pickerStyle(.wheel)
                Picker("Level", selection: $level3) {
                    ForEach(data, id: \.self) { i in
                        Text("\(i)")
                            .font(.secondaryLabel)
                    }
                }
                .pickerStyle(.wheel)
            }
            
        }
        .background(.clear)
    }
}


#Preview {
    LevelPickerView()
}
