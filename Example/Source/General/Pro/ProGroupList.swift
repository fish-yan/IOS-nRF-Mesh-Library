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
        let otherGroup = ProGroup(prefix: "未分类")
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
    
    func exportProGroup() -> Data {
        UserDefaults.standard.data(forKey: key) ?? Data()
    }
    
    func importProGroup(_ data: Data) {
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
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
    var number: Int = 1
    var maxNumber: Int = 10000
    var dim: Bool = false
    var cct: Bool = false
    var angle: Bool = false
    
    var nodes: [Node] = []
    var testedNodes = [TestedNode]()
        
    enum CodingKeys: String, CodingKey {
        case prefix
        case number
        case maxNumber
        case dim
        case cct
        case angle
        case testedNodes
    }
    
    init(prefix: String) {
        self.prefix = prefix
    }
    
    public static func == (lhs: ProGroup, rhs: ProGroup) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(prefix)
        hasher.combine(number)
        hasher.combine(maxNumber)
        hasher.combine(cct)
        hasher.combine(dim)
        hasher.combine(angle)
        hasher.combine(nodes)
        hasher.combine(testedNodes)
    }
    
    public func copy() -> ProGroup {
        let newGroup = ProGroup(prefix: prefix)
        newGroup.number = number
        newGroup.maxNumber = maxNumber
        newGroup.cct = cct
        newGroup.dim = dim
        newGroup.angle = angle
        newGroup.nodes = nodes
        newGroup.testedNodes = testedNodes
        return newGroup
    }
}

public class TestedNode: Codable, Equatable, Hashable {
    var name: String?
    var unicastAddress: String
    var UUID: UUID
    
    init(name: String?, unicastAddress: String, UUID: UUID) {
        self.name = name
        self.unicastAddress = unicastAddress
        self.UUID = UUID
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case unicastAddress
        case UUID
    }
    
    public static func == (lhs: TestedNode, rhs: TestedNode) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(unicastAddress)
        hasher.combine(UUID)
    }
}
