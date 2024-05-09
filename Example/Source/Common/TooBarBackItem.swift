//
//  TooBarBackItem.swift
//  nRF Mesh
//
//  Created by yan on 2024/5/6.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct TooBarBackItem: ToolbarContent {
    @Environment(\.dismiss) var dismiss
    @State var title: String?

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack {
                Image(systemName: "chevron.left")
                if let title {
                    Text(title)
                }
            }
            .font(.labelTitle)
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            .background(
                Color.tertiaryBackground
                    .clipShape(.rect(bottomTrailingRadius: 16, topTrailingRadius: 16))
            )
            .offset(x: -15)
            .onTapGesture(perform: backAction)
        }
    }
    
    func backAction() {
        dismiss.callAsFunction()
    }
}
