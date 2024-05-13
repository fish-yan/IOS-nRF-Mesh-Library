//
//  SliderView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/21.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct SliderView: View {
    var text: String
    var value: Binding<Double>
    var bounds: ClosedRange<Double> = 0...100
    var unit: String = "%"
    var onEditingChanged: (Bool) -> Void = { _ in }
    var onDragEnd: () -> Void = { }
    init(_ text: String, value: Binding<Double>, in bounds: ClosedRange<Double> = 0...100, unit: String = "%", onEditingChanged: @escaping (Bool) -> Void = { _ in }, onDragEnd: @escaping () -> Void = { }) {
        self.text = text
        self.value = value
        self.bounds = bounds
        self.unit = unit
        self.onEditingChanged = onEditingChanged
        self.onDragEnd = onDragEnd
    }
    
    var body: some View {
        VStack(alignment: .leading, content: {
            Text("\(text): \(String(format: "%.f", value.wrappedValue))\(unit)")
            Slider<Text, Text>(
                value: value,
                in: bounds,
                step: 1,
                onEditingChanged: { isEditing in
                    debouncer.call {
                        onEditingChanged(isEditing)
                    }
                    if !isEditing {
                        onDragEnd()
                    }
                },
                minimumValueLabel: Text("\(String(format: "%.f", bounds.lowerBound))"),
                maximumValueLabel: Text("\(String(format: "%.f", bounds.upperBound))"),
                label: { Text(text) }
            )
        })
    }
}

