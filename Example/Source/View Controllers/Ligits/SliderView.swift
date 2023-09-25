//
//  SliderView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/21.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct SliderView: View {
    @State var value: Double = 0
    var title: String = ""
    var range: ClosedRange<Double> = 0...100
    var body: some View {
        VStack(alignment: .leading, content: {
            Text(title)
            Slider(value: $value, in: range) { isEditing in
                print(isEditing)
            }
        })
    }
}

#Preview {
    SliderView()
}
