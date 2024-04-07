//
//  BeamView.swift
//  test
//
//  Created by yan on 2024/1/24.
//

import SwiftUI

struct BeamShapeView: View {
    var angle: Binding<Double>
//    @State private var startValue = 0.0
//    @State private var startLocation: CGPoint = .zero
    // 0-1, yellow - blue
    var hue: Double = 0.5
    var brightness: Double = 1

    init(angle: Binding<Double>, hue: Double = 0.5, brightness: Double = 1) {
        self.angle = angle
        self.hue = hue
        self.brightness = brightness
    }

    var body: some View {
        VStack {
            GeometryReader(content: { geometry in
                let y: CGFloat = 80
                let centerX = geometry.size.width / 2
                let height: Double = geometry.size.height - y - 50.0
                let degress = angle.wrappedValue * 50 + 10
                let harfWidth = tan(Angle(degrees: degress/2).radians) * height
                let s = hue * 0.4
                let color = Color(hue: 0.08, saturation: s, brightness: 1)
                ZStack {
                    Path { path in
                        path.move(to: CGPoint(x: centerX, y: y))
                        path.addLine(to: CGPoint(x: centerX - harfWidth, y: y + height))
                        path.addLine(to: CGPoint(x: centerX + harfWidth, y: y + height))
                        path.closeSubpath()
                    }
                    .fill(color.opacity(brightness * 0.9))
                    Path { path in
                        path.addEllipse(in: CGRect(x: centerX - harfWidth, y: y + height - harfWidth/4, width: harfWidth * 2, height: harfWidth/2))
                    }
                    .fill(color.opacity(brightness * 0.9))
                }
                .animation(.easeInOut, value: angle.wrappedValue)
            })
        }
//        .gesture(
//            MagnifyGesture()
//                .onChanged({ magnifyValue in
//                    if startLocation != magnifyValue.startLocation {
//                        startLocation = magnifyValue.startLocation
//                        startValue = angle.wrappedValue
//                    }
//                    let value = startValue * magnifyValue.magnification
//                    angle.wrappedValue = max(min(value, 1), 0.1667)
//                })
//        )
    }
}

#Preview {
    BeamShapeView(angle: .constant(1))
}
