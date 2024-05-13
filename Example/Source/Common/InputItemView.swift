//
//  InputItemView.swift
//  test
//
//  Created by yan on 2024/5/7.
//

import SwiftUI

struct InputItemView: View {
    private let title: String
    private let placehoder: String
    @State private var text: Binding<String>
    
    init(title: String, placehoder: String, text: Binding<String>) {
        self.title = title
        self.placehoder = placehoder
        self.text = text
    }
    
    var body: some View {
        HStack {
            Text(title)
                .frame(width: 72, alignment: .leading)
                .multilineTextAlignment(.leading)
            Divider()
                .padding(10)
                .frame(width: 1)
            TextField(placehoder, text: text)
        }
        .font(.label)
        .padding(9)
        .frame(height: 52)
    }
}

#Preview {
    VStack {
        Spacer()
        InputItemView(title: "Name", placehoder: "Scene Name", text: .constant(""))
            .frame(height: 40)
            .background(.white)
        Spacer()
    }
    .background(Color.secondaryBackground)
}
