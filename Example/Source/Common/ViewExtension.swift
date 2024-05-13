//
//  ViewExtension.swift
//  nRF Mesh
//
//  Created by yan on 2024/5/9.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

extension View {
    func sheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        ZStack {
            self
            Color.black.opacity(0.3).ignoresSafeArea(.all)
                .opacity(isPresented.wrappedValue ? 1 : 0)
                .animation(.easeInOut, value: isPresented.wrappedValue)
            if isPresented.wrappedValue {
                VStack {
                    Spacer()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.01))
                        .onTapGesture {
                            isPresented.wrappedValue = false
                        }
                    content()
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
                .animation(.spring)
            }
        }
    }
}
