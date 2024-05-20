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
    var touchable = false
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(!touchable && isPresented)
            if isPresented {
                ProgressView()
                    .scaleEffect(1.2)
                .frame(width: 30, height: 30)
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
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
    func loadingable() -> some View {
        return self.modifier(Loading())
    }
}
