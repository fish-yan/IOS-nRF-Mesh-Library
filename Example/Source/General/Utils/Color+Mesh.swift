//
//  Color+Mesh.swift
//  nRF Mesh
//
//  Created by yan on 2024/3/30.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

public extension Color {
        
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    
    static let groupedBackground = Color(uiColor: .systemGroupedBackground)
    
    static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
    
    static let primary = Color("primary")
    
    static let red = Color("red")
    
}

public extension Color {
    var invert: Color {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat =  0
        let color = UIColor(self)
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color(red: 1-r, green: 1-g, blue: 1-b).opacity(a)
    }
}

