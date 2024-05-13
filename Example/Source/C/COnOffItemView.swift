//
//  COnOffItemView.swift
//  nRF Mesh
//
//  Created by yan on 2024/4/2.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct COnOffItemView: View {
    let isSelected: Bool
    let icon: ImageResource
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(icon)
                .resizable()
                .frame(width: 18, height: 18)
            Text(title)
                .font(.labelTitle)
        }
        .foregroundStyle(isSelected ? Color.red : Color.accent)
        .frame(maxWidth: .infinity)
    }
}
