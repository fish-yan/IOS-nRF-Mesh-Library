//
//  VerticalControl.swift
//  test
//
//  Created by yan on 2024/1/24.
//

import SwiftUI

enum VerticalControlType {
    case dim, cct
    
    var colors: [Color] {
        switch self {
        case .dim:
            [Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)), Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))]
        case .cct:
            [Color(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)), Color(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))]
        }
    }
    
    var title: String {
        switch self {
        case .dim:
            "DIM"
        case .cct:
            "CCT"
        }
    }
}

struct VerticalControl: View {
    let type: VerticalControlType
    var value: Binding<Double>
    var endValue: Binding<Double>
    private var onAdd: ()->Void
    private var onSubtract: ()->Void
    
    init(type: VerticalControlType, value: Binding<Double>, endValue: Binding<Double>, onAdd: @escaping ()->Void = {}, onSubtract: @escaping ()->Void = {}) {
        self.type = type
        self.value = value
        self.endValue = endValue
        self.onAdd = onAdd
        self.onSubtract = onSubtract
    }
    var body: some View {
        VStack {
            Spacer()
            Button("+") {
                onAdd()
                endValue.wrappedValue = value.wrappedValue
            }
            Spacer()
                .frame(minHeight: 30, maxHeight: 100)
            Text(type.title)
                .rotationEffect(.degrees(90))
            Spacer()
                .frame(minHeight: 30, maxHeight: 100)
            Button("-") {
                onSubtract()
                endValue.wrappedValue = value.wrappedValue
            }
            Spacer()
        }
        .foregroundStyle(Color.white)
        .font(.title)
        .frame(width: 60, height: 250)
        .background(LinearGradient(colors: type.colors, startPoint: .top, endPoint: .bottom))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .gesture(
            DragGesture()
                .onChanged({ dragValue in
                    let v = endValue.wrappedValue - dragValue.translation.height/250
                    value.wrappedValue = max(min(v, 1), 0)
                })
                .onEnded({ dragValue in
                    endValue.wrappedValue = value.wrappedValue
                })
        )
    }
}

#Preview {
    VerticalControl(type: .cct, value: .constant(0.5), endValue: .constant(0.5))
}
