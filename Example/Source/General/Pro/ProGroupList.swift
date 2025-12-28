//
//  ProGroupList.swift
//  nRF Mesh
//
//  Created by yan on 2025-12-27.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import NordicMesh

public class ProGroupManager {
    static let shared = ProGroupManager()
    private let key = "proGroupList"
    
    func loadGroups() -> [ProGroup] {
        let listData = UserDefaults.standard.data(forKey: key)
        let decoder = JSONDecoder()
        var list = (try? decoder.decode([ProGroup].self, from: listData ?? Data()))?.reversed() ?? []
        let otherGroup = ProGroup(prefix: "未分类", number: 0, maxNumber: 10000)
        let nodes = MeshNetworkManager.instance.meshNetwork!.nodes.filter { !$0.isProvisioner && $0.isLight }
        nodes.forEach { node in
            if let group = list.first(where: {node.name?.hasPrefix($0.prefix) == true}) {
                group.nodes.append(node)
            } else {
                otherGroup.nodes.append(node)
            }
        }
        if !otherGroup.nodes.isEmpty {
            list += [otherGroup]
        }
        return list
    }
        
    func add(_ group: ProGroup) {
        let listData = UserDefaults.standard.data(forKey: key)
        let decoder = JSONDecoder()
        var list: [ProGroup] = (try? decoder.decode([ProGroup].self, from: listData ?? Data())) ?? []
        list.removeAll { $0.prefix == group.prefix }
        list.append(group)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(list) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func remove(_ group: ProGroup) {
        let listData = UserDefaults.standard.data(forKey: key)
        let decoder = JSONDecoder()
        var list: [ProGroup] = (try? decoder.decode([ProGroup].self, from: listData ?? Data())) ?? []
        list.removeAll { $0.prefix == group.prefix }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(list) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

public class ProGroup: Codable, Equatable, Hashable {
    var prefix: String
    var number: Int
    var maxNumber: Int
    
    var nodes: [Node] = []
    
    enum CodingKeys: String, CodingKey {
        case prefix
        case number
        case maxNumber
    }
    
    init(prefix: String, number: Int, maxNumber: Int) {
        self.prefix = prefix
        self.number = number
        self.maxNumber = maxNumber
    }
    
    public static func == (lhs: ProGroup, rhs: ProGroup) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(prefix)
        hasher.combine(number)
        hasher.combine(maxNumber)
        hasher.combine(nodes)
    }
}
