//
//  nRF Mesh
//
//  Created by yan on 2023/10/28.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Combine
import NordicMesh

class MessageDetailStore: NSObject, ObservableObject, Codable {
    
    @Published var isOn: Bool?
    
    @Published var isAi: Bool = true
    @Published var isSensor: Bool = true
    @Published var emergencyOnOff: Bool?
    
    @Published var level: Double = 0
    @Published var CCT: Double = 0
    @Published var angle: Double = 0
    
    @Published var level0: Double = 100
    @Published var level1: Double = 70
    @Published var level2: Double = 50
    @Published var level3: Double = 20
    
    @Published var runTime: Double = 300
    @Published var fadeTime: Double = 60
    
    @Published var isError: Bool = false
    @Published var error: ErrorType = .none
    
    @Published var selectedScene: SceneNumber = 0
    
    @Published var scenes: [NordicMesh.Scene] = []
    
    @Published var allScenes: [NordicMesh.Scene] = MeshNetworkManager.instance.meshNetwork?.scenes ?? []
    
    func updateScene(node: Node) {
        scenes = node.scenes
    }
    
    func updateScene(group: NordicMesh.Group) {
        scenes = group.scenes
    }
    
    override init() {}
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isOn = try? values.decode(Bool.self, forKey: .isOn)
        isAi = try values.decode(Bool.self, forKey: .isAi)
        isSensor = try values.decode(Bool.self, forKey: .isSensor)
        emergencyOnOff = try? values.decode(Bool.self, forKey: .emergencyOnOff)
        level = try values.decode(Double.self, forKey: .level)
        CCT = try values.decode(Double.self, forKey: .CCT)
        angle = try values.decode(Double.self, forKey: .angle)
        level0 = try values.decode(Double.self, forKey: .level0)
        level1 = try values.decode(Double.self, forKey: .level1)
        level2 = try values.decode(Double.self, forKey: .level2)
        level3 = try values.decode(Double.self, forKey: .level3)
        runTime = try values.decode(Double.self, forKey: .runTime)
        fadeTime = try values.decode(Double.self, forKey: .fadeTime)
        selectedScene = try values.decode(SceneNumber.self, forKey: .selectedScene)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isOn, forKey: .isOn)
        try container.encode(isAi, forKey: .isAi)
        try container.encode(isSensor, forKey: .isSensor)
        try container.encode(emergencyOnOff, forKey: .emergencyOnOff)
        try container.encode(level, forKey: .level)
        try container.encode(CCT, forKey: .CCT)
        try container.encode(angle, forKey: .angle)
        try container.encode(level0, forKey: .level0)
        try container.encode(level1, forKey: .level1)
        try container.encode(level2, forKey: .level2)
        try container.encode(level3, forKey: .level3)
        try container.encode(runTime, forKey: .runTime)
        try container.encode(fadeTime, forKey: .fadeTime)
        try container.encode(selectedScene, forKey: .selectedScene)
    }
    
    enum CodingKeys: String, CodingKey {
        case isOn, isAi, isSensor, emergencyOnOff, level, CCT, angle, level0, level1, level2, level3, runTime, fadeTime, selectedScene
    }
    
}

class GLZone: ObservableObject, Codable, Hashable {
    @Published var name: String = "Zone"
    @Published var number: UInt8 = 0x0
    @Published var nodeAddresses: [Address] = [] // 关联 node
    func scenes() -> [Scene] {
        let scenes = MeshNetworkManager.instance.meshNetwork?.nodes.filter({nodeAddresses.contains($0.primaryUnicastAddress)})
            .flatMap({$0.scenes})
            .uniqued() ?? []
        let others = scenes
            .filter { $0.number > 4 }
        let defaultScenes =  [3, 2, 1, 4].compactMap { num in
            scenes.first(where: {$0.number == num})
        }
        return defaultScenes + others
    }
    
    @Published var store: MessageDetailStore = MessageDetailStore() // zone 中操作状态保存
    
    private var anyCancellable: AnyCancellable?
    
    init(name: String, number: UInt8) {
        self.name = name
        self.number = number
        anyCancellable = self.store.objectWillChange.sink {
            self.objectWillChange.send()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name, number, nodeAddresses, store
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        number = try values.decode(UInt8.self, forKey: .number)
        
        let addresses = try values.decode([Address].self, forKey: .nodeAddresses)
        let allAddress = MeshNetworkManager.instance.meshNetwork?.nodes.map({$0.primaryUnicastAddress}) ?? []
        nodeAddresses = addresses.filter({allAddress.contains($0)})
        anyCancellable = self.store.objectWillChange.sink {
            self.objectWillChange.send()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(number, forKey: .number)
        let allAddress = MeshNetworkManager.instance.meshNetwork?.nodes.map({$0.primaryUnicastAddress}) ?? []
        let addresses = nodeAddresses.filter({allAddress.contains($0)})
        nodeAddresses = addresses
        try container.encode(addresses, forKey: .nodeAddresses)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(number)
    }
    
    static func == (lhs: GLZone, rhs: GLZone) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func add(nodeAddress: Address) {
        let zones = GLMeshNetworkModel.instance.zones
        for zone in zones where zone.number != 0 {
            zone.nodeAddresses.removeAll(where: {$0 == nodeAddress})
        }
        let allAddress = MeshNetworkManager.instance.meshNetwork?.nodes.map({$0.primaryUnicastAddress}) ?? []
        
        let all = GLMeshNetworkModel.instance.allZone
        all.nodeAddresses.append(nodeAddress)
        all.nodeAddresses = all.nodeAddresses
            .filter({allAddress.contains($0)})
            .uniqued()
        nodeAddresses.append(nodeAddress)
        nodeAddresses = nodeAddresses
            .filter({allAddress.contains($0)})
            .uniqued()
    }
    
    func remove(nodeAddress: Address) {
        let all = GLMeshNetworkModel.instance.allZone
        all.nodeAddresses.removeAll(where: {$0 == nodeAddress})
        nodeAddresses.removeAll(where: {$0 == nodeAddress})
    }
}

class GLMeshNetworkModel: ObservableObject, Codable {
    static let instance: GLMeshNetworkModel = GLMeshNetworkModel()
    private init() { }
    
    @Published fileprivate(set) var zones: [GLZone] = []
    
    @Published fileprivate var nodeCoordinates: [Address: String] = [:]
    
    enum CodingKeys: String, CodingKey {
        case nodes, groups, scenes, drafts, zones, nodeCoordinates
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        zones = (try? values.decode([GLZone].self, forKey: .zones)) ?? []
        nodeCoordinates = try values.decode([Address: String].self, forKey: .nodeCoordinates)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(zones, forKey: .zones)
        try container.encode(nodeCoordinates, forKey: .nodeCoordinates)
    }
    
    func reset() {
        zones.removeAll()
    }
    
    func nextZone() -> UInt8 {
        var next: UInt8 = 0
        let sortedZone = zones.sorted(by: {$0.number < $1.number})
        for zone in sortedZone {
            if zone.number > next {
                break
            }
            next += 1
        }
        return next
    }
    
    func zone(node: Node) -> GLZone {
        if let zone = zones.first(where: {$0.nodeAddresses.contains(node.primaryUnicastAddress) && $0.number != 0}) {
            return zone
        }
        return allZone
    }
    
    var allZone: GLZone {
        zones.first(where: {$0.number == 0}) ?? GLZone(name: "All", number: 0x0)
    }
    
    func remove(_ zone: GLZone) {
        zones.removeAll(where: { $0 == zone })
    }
    
    func add(_ zone: GLZone) {
        if zones.contains(zone) {
            return
        }
        zones.append(zone)
    }
}
private let storage: Storage = LocalStorage(fileName: "GLModel.json")
extension MeshNetworkManager {
    
    @discardableResult
    func loadAll() -> Bool {
        let success = (try? load()) ?? false
        loadModel()
        return success
    }
    
    @discardableResult
    func loadModel() -> Bool {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = storage.load(),
            let model = try? decoder.decode(GLMeshNetworkModel.self, from: data) {
            GLMeshNetworkModel.instance.zones = model.zones
            GLMeshNetworkModel.instance.nodeCoordinates = model.nodeCoordinates
            print("model load success")
            return true
        }
        return false
    }
    
    func exportGLModel() -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .withoutEscapingSlashes
        if #available(iOS 11.0, *) {
            encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        }
        return try! encoder.encode(GLMeshNetworkModel.instance)
    }
    
    func importGLModel(from data: Data) throws -> GLMeshNetworkModel {
        let decoder = JSONDecoder()
        
        // The .iso8601 decoding strategy does not support fractional seconds.
        // decoder.dateDecodingStrategy = .iso8601
        
        // Instead, use ISO8601DateFormatter.
        decoder.dateDecodingStrategy = .custom { decoder in
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions.insert(.withFractionalSeconds)
            
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            return formatter.date(from: value) ?? Date.distantPast
        }
        
        let model = try decoder.decode(GLMeshNetworkModel.self, from: data)
        GLMeshNetworkModel.instance.zones = model.zones
        GLMeshNetworkModel.instance.nodeCoordinates = model.nodeCoordinates
        return model
    }
    
    @discardableResult
    func saveAll() -> Bool {
        let success = save()
        let isModelSaved = saveModel()
        if isModelSaved {
            print("model save success")
        }
        return success
    }
    
    @discardableResult
    func saveModel() -> Bool {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .withoutEscapingSlashes
        
        let data = try! encoder.encode(GLMeshNetworkModel.instance)
        return storage.save(data)
    }
    
    @discardableResult
    func clearAll() -> Bool {
        let success = clear()
        clearModel()
        return success
    }
    
    @discardableResult
    func clearModel() -> Bool {
        GLMeshNetworkModel.instance.reset()
        return saveModel()
    }
}

extension Node {
    var coordinate: String? {
        get {
            GLMeshNetworkModel.instance.nodeCoordinates[primaryUnicastAddress]
        }
        set {
            if let newValue {
                GLMeshNetworkModel.instance.nodeCoordinates[primaryUnicastAddress] = newValue
            } else {
                GLMeshNetworkModel.instance.nodeCoordinates.removeValue(forKey: primaryUnicastAddress)
            }
        }
    }
}


enum ErrorType {
    case none
    case messageError(_ value: String)
    case bearerError
    
    var message: String {
        switch self {
        case .none:
            ""
        case .messageError(let value):
            value
        case .bearerError:
            "bearer is not connected"
        }
    }
}
