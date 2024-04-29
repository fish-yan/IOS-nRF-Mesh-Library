//
//  nRF Mesh
//
//  Created by yan on 2023/10/28.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import Combine
import nRFMeshProvision

class MessageDetailStore: NSObject, ObservableObject, Codable {
    
    @Published var isOn: Bool?
    
    @Published var isAi: Bool = true
    @Published var isSensor: Bool = true
    @Published var emergencyOnOff: Bool = false
    
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
    
    @Published var scenes: [nRFMeshProvision.Scene] = []
    
    @Published var allScenes: [nRFMeshProvision.Scene] = MeshNetworkManager.instance.meshNetwork?.scenes ?? []
    
    func updateScene(node: Node) {
        scenes = node.scenes
    }
    
    func updateScene(group: nRFMeshProvision.Group) {
        scenes = group.scenes
    }
    
    override init() {}
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isOn = try? values.decode(Bool.self, forKey: .isOn)
        isAi = try values.decode(Bool.self, forKey: .isAi)
        isSensor = try values.decode(Bool.self, forKey: .isSensor)
        emergencyOnOff = try values.decode(Bool.self, forKey: .emergencyOnOff)
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

class GLMessageModel: ObservableObject {
    @Published var type: MessageType
    @Published var message: MeshMessage
    
    init(type: MessageType, message: MeshMessage) {
        self.type = type
        self.message = message
    }
}

class GLZone: ObservableObject, Codable, Hashable {
    @Published var name: String = "Zone"
    @Published var zone: UInt8 = 0x0
    @Published var nodeAddresses: [Address] = [] // 关联node
    @Published var sceneNumbers: [SceneNumber] = [] // 关联 scene
    
    @Published var store: MessageDetailStore = MessageDetailStore() // 去掉
    
    private var anyCancellable: AnyCancellable?
    
    init(name: String, zone: UInt8) {
        self.name = name
        self.zone = zone
        anyCancellable = self.store.objectWillChange.sink {
            self.objectWillChange.send()
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name, zone, scenes, availableScenes, store
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        zone = try values.decode(UInt8.self, forKey: .zone)
        store = try values.decode(MessageDetailStore.self, forKey: .store)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(zone, forKey: .zone)
        try container.encode(store, forKey: .store)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(zone)
    }
    
    static func == (lhs: GLZone, rhs: GLZone) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class GLMeshNetworkModel: ObservableObject, Codable {
    static let instance: GLMeshNetworkModel = GLMeshNetworkModel()
    private init() { }
    
    @Published var zone: [GLZone] = []
    
    enum CodingKeys: String, CodingKey {
        case nodes, groups, scenes, drafts, zone
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        zone = try values.decode([GLZone].self, forKey: .zone)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(zone, forKey: .zone)
    }
    
    func reset() {
        zone.removeAll()
    }
    
    func nextZone() -> UInt8 {
        let sortedZone = zone.sorted(by: {$0.zone < $1.zone})
        if let last = sortedZone.last {
            return last.zone + 1
        } else {
            return 0
        }
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
            GLMeshNetworkModel.instance.zone = model.zone
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
        GLMeshNetworkModel.instance.zone = model.zone
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
