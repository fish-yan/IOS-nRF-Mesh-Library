//
//  ProLightListView.swift
//  nRF Mesh
//
//  Created by yan on 2025-12-27.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI

import NordicMesh

struct ProLightListView: View {
    @EnvironmentObject var appManager: AppManager
    @State var list: [ProGroup] = []
    @State private var searchText = ""
    @State private var expanded: Set<String> = []
    @State private var isPresented = false
    
    var filterGroups: [ProGroup] {
        if searchText.isEmpty {
            list
        } else {
            list.compactMap { group in
                let newGroup = group.copy()
                let filterNodes = group.nodes.filter({(($0.name ?? "").lowercased().contains(searchText.lowercased()) == true) || $0.primaryUnicastAddress == UInt16(searchText, radix: 16)})
                newGroup.nodes = filterNodes
                print(filterNodes)
                return filterNodes.isEmpty ? nil : newGroup
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $appManager.pro.path) {
            List(filterGroups, id: \.self) { group in
                Section {
                    if expanded.contains(group.prefix) || !searchText.isEmpty {
                        sectionItems(for: group)
                    }
                } header: {
                    sectionHeader(for: group)
                }
            }
            .listStyle(.insetGrouped)
            .listRowSpacing(10)
            .toolbar {
                NavigationLink(value: NavPath.proGroupListView(group: nil)) {
                    Image(systemName: "plus")
                }
            }
            .searchable(text: $searchText, prompt: "Name, Unicast Address")
            .navigationTitle("Lights")
            .background(Color.groupedBackground)
            .onAppear(perform: onAppera)
            .navigationDestination(for: NavPath.self) { target in
                switch target {
                case .proLightView(let node, let group):
                    ProLightView(node: node, group: group)
                case .proGroupListView(let group):
                    ProAddGroupView(group: group)
                case .proScanner(let group):
                    ProScannerView(group: group) { node in
                        appManager.pro.path.append(.proLightView(node: node, group: group!))
                    }
                default: Text("")
                }
            }
        }
    }
    
    private func sectionItems(for group: ProGroup) -> some View {
        ForEach(group.nodes, id: \.self) { node in
            NavigationLink(value: NavPath.proLightView(node: node, group: group)) {
                VStack(alignment: .leading, spacing: 13) {
                    Text(node.name ?? "Unknow")
                        .font(.labelTitle)
                        .foregroundStyle(Color.accent)
                    (Text("Address") +
                     Text(": 0x\(node.primaryUnicastAddress.hex)"))
                    .font(.secondaryLabel)
                    .foregroundColor(Color.secondaryLabel)
                    if let coordinate = node.coordinate {
                        let zone = GLMeshNetworkModel.instance.zone(node: node)
                        (Text("Position") +
                         Text(": 0x\(String(zone.number, radix: 16))\(coordinate.replacingOccurrences(of: "Unknown", with: ""))"))
                        .font(.secondaryLabel)
                        .foregroundColor(Color.secondaryLabel)
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listSectionSpacing(0)
            .listRowBackground(Color.tertiaryBackground)
        }
    }
    
    private func sectionHeader(for group: ProGroup) -> some View {
        Button {
            withAnimation {
                if expanded.contains(group.prefix) {
                    expanded.remove(group.prefix)
                } else {
                    expanded.insert(group.prefix)
                }
            }
        } label: {
            VStack {
                HStack {
                    Text("\(group.prefix)")
                    if group.prefix != "未分类" {
                        Text("最大：\(group.maxNumber)")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryLabel)
                        Spacer()
                        NavigationLink(value: NavPath.proGroupListView(group: group)) {
                            Image(systemName: "pencil.line")
                        }
                        Spacer()
                            .frame(width: 20)
                        Button {
                            if group.number > group.maxNumber {
                                showError("该系列已到最大数量")
                            } else {
                                appManager.pro.path.append(.proScanner(group: group))
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                        Spacer()
                            .frame(width: 20)
                    } else {
                        Spacer()
                    }
                    Image(systemName: "chevron.right")
                        .rotationEffect(expanded.contains(group.prefix) ? .degrees(90) : .degrees(0))
                }
            }
        }
    }
}

private extension ProLightListView {
    func onAppera() {
        list = []
        list = ProGroupManager.shared.loadGroups()
    }
}

#Preview {
    ProLightListView()
}
