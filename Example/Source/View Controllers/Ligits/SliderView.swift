//
//  SliderView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/21.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct SliderView: View {
    @Binding var value: Double
    var title: String = ""
    var range: ClosedRange<Double> = 0...4
    var onEditingChanged: (Bool) -> Void = { _ in }
    var body: some View {
        VStack(alignment: .leading, content: {
            Text(title)
            Slider(value: $value, in: range, step: 1) { isEditing in
                debouncer.call {
                    onEditingChanged(isEditing)
                }
            }
        })
    }
}
