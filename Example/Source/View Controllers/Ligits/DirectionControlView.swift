//
//  DirectionControlView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/21.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct DirectionControlView: View {
    private let strokeColor = Color(white: 0.5, opacity: 0.2)
    
    var onChange: ((Direction) -> Void)?
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.gray.opacity(0.3), radius: 10, y: 8)
                .overlay {
                    Line()
                        .stroke(strokeColor, lineWidth: 1)
                        .rotationEffect(.degrees(45))
                    
                    Line()
                        .stroke(strokeColor, lineWidth: 1)
                        .rotationEffect(.degrees(-45))
                }
            
            VStack {
                Button(action: {
                    onChange?(.up)
                }, label: {
                    Image(systemName: "chevron.up")
                        .font(.title2)
                        .frame(width: 50, height: 50)
                })
                Spacer().frame(height: 50)
                Button(action: {
                    onChange?(.down)
                }, label: {
                    Image(systemName: "chevron.down")
                        .font(.title2)
                        .frame(width: 50, height: 50)
                })
            }
            HStack {
                Button(action: {
                    onChange?(.left)
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .frame(width: 50, height: 50)
                })
                Spacer().frame(width: 50)
                Button(action: {
                    onChange?(.right)
                }, label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .frame(width: 50, height: 50)
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 150, alignment: .center)
    }
}

enum Direction {
    case up, left, down, right
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

#Preview {
    DirectionControlView()
}
