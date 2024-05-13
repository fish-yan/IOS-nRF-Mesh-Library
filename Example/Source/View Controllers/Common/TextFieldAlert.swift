//
//  TextFieldAlert.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/27.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct TextFieldAlert: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    @Binding var text: String
    let placeholder: String
    let isSecured: Bool
    let action: (String) -> Void
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            content
                .disabled(isPresented)
            Color.gray.opacity(0.4)
            if isPresented {
                VStack {
                    Text(title).font(.headline).padding()
                    if isSecured {
                        SecureField(placeholder, text: $text).textFieldStyle(.roundedBorder).padding()
                    } else {
                        TextField(placeholder, text: $text).textFieldStyle(.roundedBorder).padding()
                    }
                    Divider()
                    HStack{
                        Spacer()
                        Button(role: .cancel) {
                            withAnimation {
                                isPresented.toggle()
                            }
                        } label: {
                            Text("Cancel")
                        }
                        Spacer()
                        Divider()
                        Spacer()
                        Button() {
                            action(text)
                            withAnimation {
                                isPresented.toggle()
                            }
                        } label: {
                            Text("Done")
                        }
                        Spacer()
                    }
                }
                .background(.background)
                .frame(width: 300, height: 200)
                .cornerRadius(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.quaternary, lineWidth: 1)
                }
            }
        }
    }
}


struct UniAlertViewModel {
    
    let backgroundColor: Color = Color.gray.opacity(0.4)
    let contentBackgroundColor: Color = Color.white.opacity(1)
    let contentPadding: CGFloat = 16
    let contentCornerRadius: CGFloat = 12
}

struct UniAlertButton {
    
    enum Variant {
        
        case destructive
        case regular
    }
    
    let content: AnyView
    let action: () -> Void
    let type: Variant
    
    var isDestructive: Bool {
        type == .destructive
    }
    
    static func destructive<Content: View>(
        @ViewBuilder content: @escaping () -> Content
    ) -> UniAlertButton {
        UniAlertButton(
            content: content,
            action: { /* close */ },
            type: .destructive)
    }
    
    static func regular<Content: View>(
        @ViewBuilder content: @escaping () -> Content,
        action: @escaping () -> Void
    ) -> UniAlertButton {
        UniAlertButton(
            content: content,
            action: action,
            type: .regular)
    }
    
    private init<Content: View>(
        @ViewBuilder content: @escaping () -> Content,
        action: @escaping () -> Void,
        type: Variant
    ) {
        self.content = AnyView(content())
        self.type = type
        self.action = action
    }
}

struct UniAlert<Presenter, Content>: View where Presenter: View, Content: View {
    
    @Binding private (set) var isShowing: Bool
    
    let displayContent: Content
    let buttons: [UniAlertButton]
    let presentationView: Presenter
    let viewModel: UniAlertViewModel
    
    private var requireHorizontalPositioning: Bool {
        let maxButtonPositionedHorizontally = 2
        return buttons.count > maxButtonPositionedHorizontally
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor()
                
                VStack {
                    Spacer()
                    
                    ZStack {
                        presentationView.disabled(isShowing)
                        let expectedWidth = geometry.size.width * 0.7
                        
                        VStack {
                            displayContent
                            buttonsPad(expectedWidth)
                        }
                        .padding(viewModel.contentPadding)
                        .background(viewModel.contentBackgroundColor)
                        .cornerRadius(viewModel.contentCornerRadius)
                        .shadow(radius: 1)
                        .opacity(self.isShowing ? 1 : 0)
                        .frame(
                            minWidth: expectedWidth,
                            maxWidth: expectedWidth
                        )
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    private func backgroundColor() -> some View {
        viewModel.backgroundColor
            .edgesIgnoringSafeArea(.all)
            .opacity(self.isShowing ? 1 : 0)
    }
    
    private func buttonsPad(_ expectedWidth: CGFloat) -> some View {
        VStack {
            if requireHorizontalPositioning {
                verticalButtonPad()
            } else {
                Divider().padding([.leading, .trailing], -viewModel.contentPadding)
                horizontalButtonsPadFor(expectedWidth)
            }
        }
    }
    
    private func verticalButtonPad() -> some View {
        VStack {
            ForEach(0..<buttons.count, id: \.self) {
                Divider().padding([.leading, .trailing], -viewModel.contentPadding)
                let current = buttons[$0]
                
                Button(action: {
                    if !current.isDestructive {
                        current.action()
                    }
                    
                    withAnimation {
                        self.isShowing.toggle()
                    }
                }, label: {
                    current.content.frame(height: 35)
                })
            }
        }
    }
    
    private func horizontalButtonsPadFor(_ expectedWidth: CGFloat) -> some View {
        HStack {
            let sidesOffset = viewModel.contentPadding * 2
            let maxHorizontalWidth = requireHorizontalPositioning ?
            expectedWidth - sidesOffset :
            expectedWidth / 2 - sidesOffset
            
            Spacer()
            
            if !requireHorizontalPositioning {
                ForEach(0..<buttons.count, id: \.self) {
                    if $0 != 0 {
                        Divider().frame(height: 44)
                    }
                    let current = buttons[$0]
                    
                    Button(action: {
                        if !current.isDestructive {
                            current.action()
                        }
                        
                        withAnimation {
                            self.isShowing.toggle()
                        }
                    }, label: {
                        current.content
                    })
                    .frame(maxWidth: maxHorizontalWidth, minHeight: 44)
                }
            }
            Spacer()
        }
    }
}

public struct TextFieldAlertModifier: ViewModifier {

    @State private var alertController: UIAlertController?

    @Binding var isPresented: Bool

    let title: String
    let text: String
    let placeholder: String
    let isSecured: Bool
    let action: (String?) -> Void

    public func body(content: Content) -> some View {
        content.onChange(of: isPresented) { isPresented in
            if isPresented, alertController == nil {
                let alertController = makeAlertController()
                self.alertController = alertController
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    return
                }
                scene.windows.first?.rootViewController?.present(alertController, animated: true)
            } else if !isPresented, let alertController = alertController {
                alertController.dismiss(animated: true)
                self.alertController = nil
            }
        }
    }

    private func makeAlertController() -> UIAlertController {
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        controller.addTextField {
            $0.placeholder = self.placeholder
            $0.text = self.text
            $0.isSecureTextEntry = isSecured
        }
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.action(nil)
            shutdown()
        })
        controller.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.action(controller.textFields?.first?.text)
            shutdown()
        })
        return controller
    }

    private func shutdown() {
        isPresented = false
        alertController = nil
    }

}

extension View {
//    public func textFieldAlert(
//        isPresented: Binding<Bool>,
//        title: String,
//        text: Binding<String>,
//        placeholder: String = "",
//        isSecured: Bool = false,
//        action: @escaping (String) -> Void
//    ) -> some View {
//        self.modifier(TextFieldAlert(isPresented: isPresented, title: title, text: text, placeholder: placeholder, isSecured: isSecured, action: action))
//    }
    
    func textFieldAlert<Content>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        actions: [UniAlertButton]
    ) -> some View where Content: View {
        UniAlert(
            isShowing: isPresented,
            displayContent: content(),
            buttons: actions,
            presentationView: self,
            viewModel: UniAlertViewModel())
    }
    
    public func textFieldAlert(
        isPresented: Binding<Bool>,
        title: String,
        text: String = "",
        placeholder: String = "",
        isSecured: Bool = false,
        action: @escaping (String?) -> Void
    ) -> some View {
        self.modifier(TextFieldAlertModifier(isPresented: isPresented, title: title, text: text, placeholder: placeholder, isSecured: isSecured, action: action))
    }
}
