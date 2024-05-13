//
//  CustomSlider.swift
//  test
//
//  Created by yan on 2024/5/8.
//

import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...1
    var onChanged: ((Double) -> Void)?
    var onEnded: ((Double) -> Void)?
    
    var body: some View {
        GeometryReader { reader in
            let scal = range.upperBound - range.lowerBound
            let width = reader.size.width
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 2)
                    .foregroundColor(.gray.opacity(0.3))
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: value * width / scal, height: 2)
                    .foregroundColor(.black)
                ZStack {
                    Circle()
                        .frame(width: 10, height: 10)
                }
                .frame(width: 20, height: 20)
                .offset(x: value * width / scal - 10)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let changeWidth = min(max(gesture.location.x, 0), width)
                            value = Double(changeWidth / width) * scal
                            onChanged?(value)
                        }
                        .onEnded({ _ in
                            onEnded?(value)
                        })
                )
            }
        }
        .frame(height: 20)
    }
}

#Preview {
    CustomSlider(value: .constant(0.3))
}
