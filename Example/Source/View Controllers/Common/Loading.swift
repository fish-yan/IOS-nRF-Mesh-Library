//
//  Loading.swift
//  nRF Mesh
//
//  Created by yan on 2024/1/31.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct Loading: ViewModifier {
    static let showNotification = Notification.Name("Loading.showNotification")
    static let hidenNotification = Notification.Name("Loading.hidenNotification")
    @State private var isContentShowing = false
    @State private var isPresented = false
    let text: String
    var touchable = false
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                VStack {
                    ProgressView()
                        .tint(Color.white)
                        .scaleEffect(2)
                    Spacer()
                        .frame(height: 30)
                    Text(text)
                        .foregroundStyle(.white)
                        .font(.body)
                }
                .frame(width: 100, height: 100)
                .padding(20)
                .background(Color(white: 0.5))
                .cornerRadius(8)
            }
        }.onAppear(perform: {
            isContentShowing = true
        }).onDisappear(perform: {
            isContentShowing = false
        }).onReceive(NotificationCenter.default.publisher(for: Loading.showNotification)) { output in
            guard isContentShowing else {
                return
            }
            isPresented = true
        }.onReceive(NotificationCenter.default.publisher(for: Loading.hidenNotification)) { output in
            guard isContentShowing else {
                return
            }
            isPresented = false
        }
    }
    
    static func show() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Loading.showNotification, object: nil)
        }
        
    }
    
    static func hidden() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Loading.hidenNotification, object: nil)
        }
    }
}

extension View {
    func loadingable(text: String) -> some View {
        return self.modifier(Loading(text: text))
    }
}
