//
//  BeamView.swift
//  test
//
//  Created by yan on 2024/1/24.
//

import SwiftUI

struct BeamShapeView: View {
    var angle: Binding<Double>
    var endValue: Binding<Double>
    // 0-1, yellow - blue
    var hue: Double = 0.5
    var brightness: Double = 1

    init(angle: Binding<Double>, endValue: Binding<Double>, hue: Double = 0.5, brightness: Double = 1) {
        self.angle = angle
        self.endValue = endValue
        self.hue = hue
        self.brightness = brightness
    }

    var body: some View {
        VStack {
            GeometryReader(content: { geometry in
                let y: CGFloat = 100
                let centerX = geometry.size.width/2
                let height: Double = geometry.size.height - 130
                let degress = angle.wrappedValue * 60
                let harfWidth = tan(Angle(degrees: degress/2).radians) * height
                let s = (1-hue) * 0.5
                let color = Color(hue: 0.079, saturation: s, brightness: 1)
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
            HStack {
                let dotValue = 5 * angle.wrappedValue
                DotView(count: 5, direction: .rightToLeft, value: dotValue)
                Text("BEAM")
                    .frame(width: 90)
                    .foregroundStyle(.white)
                    .font(.title2)
                DotView(count: 5, direction: .leftToRight, value: dotValue)
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .background(.black)
        .gesture(
            MagnificationGesture()
                .onChanged({ magnification in
                    let value = endValue.wrappedValue * magnification
                    print(value)
                    angle.wrappedValue = max(min(value, 1), 0.1667)
                })
//            MagnifyGesture()
//                .onChanged({ magnifyValue in
//                    let value = endValue.wrappedValue * magnifyValue.magnification
//                    print(value)
//                    angle.wrappedValue = max(min(value, 1), 0.1667)
//                    
//                })
                .onEnded({ gestureValue in
                    endValue.wrappedValue = angle.wrappedValue
//                    print(endValue.wrappedValue)
                })
        )
    }
}

#Preview {
    BeamShapeView(angle: .constant(1), endValue: .constant(1))
}
