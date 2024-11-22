//
//  BeamView.swift
//  test
//
//  Created by yan on 2024/1/24.
//

import SwiftUI

struct BeamShapeView: View {
    var angle: Binding<Double>
    @State private var startValue = 0.0
    @State private var startLocation: CGPoint = .zero
    
    @State private var dragStartValue = 0.0
    @State private var dragStartLocation: CGPoint = .zero
    @GestureState private var dragOffset = CGSize.zero

    // 0-1, yellow - blue
    var hue: Double = 0.5
    var brightness: Binding<Double>
    
    private var onAngleChange: (() -> Void) = {}
    
    private var onBrightnessChange: (() -> Void) = {}

    init(angle: Binding<Double>, hue: Double = 0.5, brightness: Binding<Double>, onAngleChange: @escaping () -> Void = {}, onBrightnessChange: @escaping () -> Void = {}) {
        self.angle = angle
        self.hue = hue
        self.brightness = brightness
        self.onAngleChange = onAngleChange
        self.onBrightnessChange = onBrightnessChange
    }

    var body: some View {
        let s = hue * 0.4
        let color = Color(hue: 0.08, saturation: s, brightness: 1)
        GeometryReader { geometry in
            ZStack {
                ConeShapeView(angle: angle.wrappedValue)
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(brightness.wrappedValue * 0.9),
                                color.opacity(brightness.wrappedValue * 0.7),
                                color.opacity(brightness.wrappedValue * 0.4),
                                color.opacity(brightness.wrappedValue * 0)
                            ],
                            center: .top,
                            startRadius: geometry.size.height * (0.6 - angle.wrappedValue / 5),
                            endRadius: geometry.size.height * (0.98 - angle.wrappedValue / 5)
                        )
                    )
                    .animation(.default, value: angle.wrappedValue)
                EllipesShapeView(angle: angle.wrappedValue)
                    .fill(color.opacity(brightness.wrappedValue * 0.5))
                    .animation(.default, value: angle.wrappedValue)
                
            }
        }
        .background(Color.black.opacity(0.001))
        .offset(dragOffset)
        .gesture(
            MagnifyGesture()
                .onChanged({ magnifyValue in
                    if startLocation != magnifyValue.startLocation {
                        startLocation = magnifyValue.startLocation
                        startValue = angle.wrappedValue
                    }
                    let value = startValue * magnifyValue.magnification
                    let newValue = correct(max(min(value, 1), 0))
                    if newValue != angle.wrappedValue {
                        angle.wrappedValue = newValue
                        debouncer.call {
                            onAngleChange()
                        }
                    }
                })
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 5)
                .onChanged({ dragValue in
                    if dragStartLocation != dragValue.startLocation {
                        dragStartLocation = dragValue.startLocation
                        dragStartValue = brightness.wrappedValue
                    }
                    let value = dragStartValue + dragValue.translation.height / 500
                    let newValue = max(min(value, 1), 0)
                    if newValue != brightness.wrappedValue {
                        brightness.wrappedValue = newValue
                        debouncer.call {
                            onBrightnessChange()
                        }
                    }
                })
        )
    }
    
    func correct(_ value: Double) -> Double {
        if let values = MeshSliderType.angle.values,
           let newValue = values.min(by: { abs($0 - value) < abs($1 - value) }) {
            return newValue
        } else {
            return value
        }
    }
}

struct ConeShapeView: Shape {
    var angle: Double

    func path(in rect: CGRect) -> Path {
        let y: CGFloat = 80
        let centerX = rect.size.width / 2
        let tempHeight: Double = rect.size.height - y
        let degress = angle * 50 + 10
        let harfWidth = tan(Angle(degrees: degress/2).radians) * tempHeight
        let height: Double = rect.size.height - y - harfWidth/4 - 10
        return Path { path in
            path.move(to: CGPoint(x: centerX, y: y))
            path.addLine(to: CGPoint(x: centerX - harfWidth, y: y + height))
//            path.addArc(center: CGPoint(x: centerX, y: y + height + harfWidth/4), radius: 50, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: true)
            path.addQuadCurve(to: CGPoint(x: centerX + harfWidth, y: y + height), control: CGPoint(x: centerX, y: y + height - harfWidth/4))
            
//            path.addQuadCurve(to: CGPoint(x: centerX + harfWidth, y: y + height), control: CGPoint(x: centerX, y: y + height - harfWidth/2))
            
//            path.addEllipse(in: CGRect(x: centerX - harfWidth, y: y + height - harfWidth/4, width: harfWidth * 2, height: harfWidth/2))
//            path.addLine(to: CGPoint(x: centerX + harfWidth, y: y + height))
            path.closeSubpath()
        }
    }
    
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }
}


struct EllipesShapeView: Shape {
    var angle: Double

    func path(in rect: CGRect) -> Path {
        let y: CGFloat = 80
        let centerX = rect.size.width / 2
        let tempHeight: Double = rect.size.height - y
        let degress = angle * 50 + 10
        let harfWidth = tan(Angle(degrees: degress/2).radians) * tempHeight
        let height: Double = rect.size.height - y - harfWidth/4 - 10
        return Path { path in
            path.addEllipse(in: CGRect(x: centerX - harfWidth, y: y + height - harfWidth/4, width: harfWidth * 2, height: harfWidth/2))
        }
    }
    
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }
}

#Preview {
    @Previewable @State var angle = 0.5
    @Previewable @State var brightness: Double = 1
    BeamShapeView(angle: $angle, brightness: $brightness)
        .background(.black)
        .frame(width: 300, height: 500)
}
