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
    
    var originValues: [Double]? {
        switch self {
        case .angle: AppManager.manager.angleConfigs
        default: nil
        }
    }
    
    var values: [Double]? {
        originValues?.map { (10 + (($0 - 10) * 1.8)) / 100 }
    }
    
    var normalColor: Color {
        Color.primary
    }
    
    func formatText(value: Double) -> String {
        switch self {
        case .angle:
            let newValue = (value * 100 - 10) / 1.8 + 10
            return newValue.formatted(.number2) + "°"
        default:
            return (value * 100).formatted(.number2) + "%"
        }
    }
}

struct MeshSliderView: View {
    var value: Binding<Double>
    @State private var startValue = 0.0
    @State private var startLocation: CGPoint = .zero
    private let type: MeshSliderType
    private var onChange: (() -> Void) = {}
    private var onEnded: (() -> Void) = {}
    
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
                    Text(type.formatText(value: value.wrappedValue))
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
                            let newValue = correct(max(min(v, 1), 0))
                            if newValue != value.wrappedValue {
                                value.wrappedValue = newValue
                                debouncer.call {
                                    onChange()
                                }
                            }
                        })
                        .onEnded({ dragValue in
                            debouncer.call {
                                onEnded()
                            }
                        })
                )
            }
            .frame(height: 36)
            .clipShape(.rect(cornerRadius: 18))
        }
    }
    
    func correct(_ value: Double) -> Double {
        if let values = type.values,
           let newValue = values.min(by: { abs($0 - value) < abs($1 - value) }) {
            return newValue
        } else {
            return value
        }
    }
}

#Preview {
    @Previewable @State var value = 0.0
    return MeshSliderView(value: $value, type: .angle)
        .padding()
}

struct Number2Format: FormatStyle {
    func format(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return (formatter.string(from: NSNumber(value: value)) ?? "0")
    }
    
    typealias FormatInput = Double
    
    typealias FormatOutput = String
    
}

extension FormatStyle where Self == Number2Format {
    static var number2: Number2Format {
        return Number2Format()
    }
}
