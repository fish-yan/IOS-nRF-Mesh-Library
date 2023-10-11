//
//  UserSettingsView.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/11.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

enum UserRole: String, CaseIterable {
    case normal
    case supervisor
    case commissioner
}

struct UserSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var selectionRole: UserRole = .normal
    
    @State var l1Text: String = ""
    @State var l2Text: String = ""
    @State var l3Text: String = ""
    
    @State var OnDelayTime: String = ""
    @State var OffDelayTime: String = ""
    @State var OnTransactionTime: String = ""
    @State var OffTransactionTime: String = ""
    
    @State var isPresented = false
    
    @State var isErrorPresented = false
    
    @State var prepareRole: UserRole = .normal
        
    @State var code: String = ""
            
    var body: some View {
        List {
            Section {
                ForEach(UserRole.allCases, id: \.self) { role in
                    Button {
                        if role == .normal {
                            selectionRole = role
                        } else {
                            isPresented = true
                            prepareRole = role
                        }
                        
                    } label: {
                        HStack {
                            Text(role.rawValue.capitalized)
                                .foregroundStyle(Color(UIColor.label))
                            Spacer()
                            Image(systemName: "checkmark")
                                .opacity(role == selectionRole ? 1 : 0)
                        }
                    }
                    .alert("Please enter code", isPresented: $isPresented) {
                        SecureField("enter code", text: $code)
                        Button("OK") {
                            if prepareRole == .supervisor {
                                if code == "666666" {
                                    selectionRole = prepareRole
                                } else {
                                    isErrorPresented = true
                                }
                            }
                            if prepareRole == .commissioner {
                                if code == "888888" {
                                    selectionRole = prepareRole
                                } else {
                                    isErrorPresented = true
                                }
                            }
                            code = ""
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                    .alert("Code is error", isPresented: $isErrorPresented) {
                        Button("OK", role: .cancel) { }
                    }
                }
            }
            if selectionRole == .supervisor || selectionRole == .commissioner {
                Section {
                    UserSettingsItem(title: "L1", text: $l1Text, unit: "%")
                    UserSettingsItem(title: "L2", text: $l2Text, unit: "%")
                    UserSettingsItem(title: "L3", text: $l3Text, unit: "%")
                } header: {
                    Text("Level")
                }
                
                Section {
                    UserSettingsItem(title: "On Delay Time", text: $OnDelayTime, unit: "s")
                    UserSettingsItem(title: "Off Delay Time", text: $OffDelayTime, unit: "s")
                    UserSettingsItem(title: "On Transaction Time", text: $OnTransactionTime, unit: "s")
                    UserSettingsItem(title: "Off Transaction Time", text: $OffTransactionTime, unit: "s")
                } header: {
                    Text("Time")
                }
            }
            
            if selectionRole == .commissioner {
                Section {
                    NavigationLink("Application Key") {
                        
                    }
                    NavigationLink("Reset") {
                        
                    }
                }
            }
            
        }
        .navigationTitle("User Settings")
        .toolbar {
            Button {
                save()
            } label: {
                Text("Save")
            }

        }
    }
    
    private func save() {
        dismiss.callAsFunction()
    }
}

struct UserSettingsItem: View {
    var title: String
    @Binding var text: String
    var unit: String
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
                .frame(width: 40)
            Text(unit)
        }
    }
}

#Preview {
    UserSettingsView()
}
