//
//  SearchBar.swift
//  nRF Mesh
//
//  Created by yan on 2024/7/26.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var prompt = "Search"
    @FocusState private var isEditing: Bool
    @State private var opacity: Double = 1
    
    var body: some View {
        HStack {
            TextField(prompt, text: $text)
                .focused($isEditing)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                    }
                )
                .padding(.horizontal, 20)
            
            if isEditing {
                Button(action: {
                    text = ""
                    isEditing = false
                }) {
                    Text(Localized("Cancel"))
                        .foregroundColor(.black)
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.default, value: isEditing)
    }
}

struct TestContentView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding()
                
                // Your other content here
                
                Spacer()
            }
            .navigationBarTitle("My App")
        }
    }
}

#Preview {
    TestContentView()
}
