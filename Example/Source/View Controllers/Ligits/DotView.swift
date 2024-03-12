//
//  DotView.swift
//  test
//
//  Created by yan on 2024/1/24.
//

import SwiftUI

enum DotViewDirection {
    case bottomToTop
    case leftToRight
    case rightToLeft
}

struct DotView: View {
    var count = 6
    var direction: DotViewDirection = .bottomToTop
    var value: Double = 1
    
    var body: some View {
        if direction == .bottomToTop {
            VStack {
                circles
            }
        } else {
            HStack {
                circles
            }
        }
    }
    
    private var circles: some View {
        ForEach(0..<count, id: \.self) { i in
            ZStack {
                Circle()
                    .fill(color(i))
                Circle()
                    .stroke(.white, lineWidth: 2.5)
            }
            .frame(width: 10,height: 10)
            .padding(2)
        }
    }
    
    private func color(_ i: Int) -> Color {
        let c: Double
        if direction == .leftToRight {
            c = value
        } else {
            c = Double(count) - value
        }
        let blackCount = Int(c)
        let condition = direction == .leftToRight ? i < blackCount : i > blackCount
        if condition {
            return .blue
        } else if i == blackCount {
            let remainder = Int(c * 10) % 10
            let opacity = direction == .leftToRight ? Double(remainder)/10 : 1 - Double(remainder)/10
            return .blue.opacity(opacity)
        } else {
            return .black
        }
    }
}

#Preview {
    DotView(count: 5, direction: .leftToRight, value: 3).background(.black)
}
