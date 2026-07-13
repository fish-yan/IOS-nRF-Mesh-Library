//
//  ProAddGroupView.swift
//  nRF Mesh
//
//  Created by yan on 2025-12-27.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI

struct ProAddGroupView: View {
    @EnvironmentObject var appManager: AppManager

    @State private var prefixText: String = "0"
    @State private var maxNumberText: String = ""
    @State private var numberText: String = "1"
    
    @State private var dim: Bool = false
    @State private var cct: Bool = false
    @State private var angle: Bool = false
    private var group: ProGroup?
    
    init(group: ProGroup? = nil) {
        self.group = group
    }
    
    var body: some View {
        VStack(spacing: 10) {
            InputItemView(title: "前缀", placehoder: "输入前缀", text: $prefixText)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(group != nil)
            InputItemView(title: "编号", placehoder: "输入编号", text: $numberText, keyboardType: .numberPad)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            InputItemView(title: "最大值", placehoder: "输入编号最大值", text: $maxNumberText, keyboardType: .numberPad)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Toggle("亮度", isOn: $dim)
                .padding(9)
                .frame(height: 52)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Toggle("色温", isOn: $cct)
                .padding(9)
                .frame(height: 52)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Toggle("角度", isOn: $angle)
                .padding(9)
                .frame(height: 52)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
                .frame(height: 50)
            let disabled = prefixText.isEmpty || numberText.isEmpty || maxNumberText.isEmpty
            Button(action: saveAction, label: {
                Text("保存")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.black.opacity(disabled ? 0.3 : 1))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            })
            .disabled(disabled)
            if group != nil {
                Button(action: deleteAction, label: {
                    Text("删除")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.red)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                })
            }
            Spacer()
        }
        .padding(20)
        .navigationTitle(group?.prefix ?? "New")
        .background(Color.secondaryBackground)
        .ignoresSafeArea(.keyboard)
        .onAppear(perform: onAppear)
    }
}

private extension ProAddGroupView {
    
    func onAppear() {
        if let group {
            prefixText = group.prefix
            numberText = "\(group.number)"
            maxNumberText = "\(group.maxNumber)"
            dim = group.dim
            cct = group.cct
            angle = group.angle
        }
    }
    
    func saveAction() {
        hideKeyboard()
        guard !prefixText.isEmpty,
              let number = Int(numberText),
              let maxNumber = Int(maxNumberText) else {
            return
        }
        let groups = ProGroupManager.shared.loadGroups()
        if groups.contains(where: {$0.prefix == prefixText}) && group == nil {
            toast("已存在该前缀")
            return
        }
        
        let newGroup = group ?? ProGroup(prefix: prefixText)
        newGroup.number = number
        newGroup.maxNumber = maxNumber
        newGroup.dim = dim
        newGroup.cct = cct
        newGroup.angle = angle
        ProGroupManager.shared.add(newGroup)
        appManager.pro.pop()
    }
    
    func deleteAction() {
        guard let group else { return }
        ProGroupManager.shared.remove(group)
        appManager.pro.pop()
    }
}

#Preview {
    ProAddGroupView()
}
