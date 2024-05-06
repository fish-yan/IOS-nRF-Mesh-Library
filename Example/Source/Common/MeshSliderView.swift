//
//  MeshSliderView.swift
//  test
//
//  Created by yan on 2024/3/30.
//

import SwiftUI

enum MeshSliderType {
    case dim, cct, angle
    
    var colors: [Color] {
        switch self {
        case .dim:
            [Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.9)), Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)), Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 0.5)), Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))]
        case .cct:
            [Color(#colorLiteral(red: 0.9411764706, green: 1, blue: 0.9882352941, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.8039215686, blue: 0.3921568627, alpha: 0.5)), Color(#colorLiteral(red: 1, green: 0.8039215686, blue: 0.3921568627, alpha: 0.7)), Color(#colorLiteral(red: 1, green: 0.8039215686, blue: 0.3921568627, alpha: 1))]
        case .angle:
            [Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))]
        }
    }
    
    var image: ImageResource {
        switch self {
        case .dim:
            ImageResource.icDim
        case .cct:
            ImageResource.icCct
        case .angle:
            ImageResource.icAngle
        }
    }
    
    var title: String {
        switch self {
        case .dim:
            "DIM"
        case .cct:
            "CCT"
        case .angle:
            "Angle"
        }
    }
    
    var lightColor: Color {
        switch self {
        case .dim:
            Color.whiteLabel
        case .cct:
            Color.primary
        case .angle:
            Color.whiteLabel
        }
    }
    
    var normalColor: Color {
        Color.primary
    }
}

struct MeshSliderView: View {
    var value: Binding<Double>
    @State private var startValue = 0.0
    @State private var startLocation: CGPoint = .zero
    private let type: MeshSliderType
    private var onChange: (() -> Void) = {}
    
    init(value: Binding<Double>, type: MeshSliderType, onChange: @escaping () -> Void = {}) {
        self.type = type
        self.value = value
        self.onChange = onChange
    }
    
    var body: some View {
        HStack(spacing: 14) {
            Image(type.image)
                .foregroundStyle(Color.secondaryLabel)
            GeometryReader { reader in
                let thumbY = reader.size.height/2
                let width = reader.size.width  * value.wrappedValue
                let color = width > 20 ? type.lightColor : type.normalColor
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.itemBackground)
                    Rectangle()
                        .fill(LinearGradient(colors: type.colors, startPoint: .leading, endPoint: .trailing))
                        .mask(alignment: .leading) {
                            Color.white
                                .frame(width: width)
                        }
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.whiteLabel)
                        .frame(width: 4, height: 20)
                        .position(CGPoint(x: width - 7, y: thumbY))
                    Text("\(Int(value.wrappedValue * 100))%")
                        .position(CGPoint(x: 30.0, y: 18.0))
                        .foregroundStyle(color)
                        .shadow(color: color.invert.opacity(0.5), radius: 0.5, x: 1, y: 0)
                }
                .gesture(
                    DragGesture()
                        .onChanged({ dragValue in
                            if startLocation != dragValue.startLocation {
                                startLocation = dragValue.startLocation
                                startValue = value.wrappedValue
                            }
                            let v = dragValue.translation.width/reader.size.width + startValue
                            value.wrappedValue = max(min(v, 1), 0)
                            debouncer.call {
                                onChange()
                            }
                        })
                )
            }
            .frame(height: 36)
            .clipShape(.rect(cornerRadius: 18))
        }
    }
}

#Preview {
    @State var value = 0.0
    return MeshSliderView(value: $value, type: .angle)
        .padding()
}
