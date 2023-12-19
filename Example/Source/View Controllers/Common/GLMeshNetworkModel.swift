//
//  GLSceneModel.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/28.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

class GLSceneModel: ObservableObject, Codable {
    @Published var number: SceneNumber = 1
    
    @Published var level0: Double = 100
    @Published var level1: Double = 70
    @Published var level2: Double = 50
    @Published var level3: Double = 20
    
    @Published var cct: Double = 0
    @Published var angle: Double = 0
    
    @Published var runTime: Double = 300
    @Published var fadeTime: Double = 60
    
    @Published var isAi: Bool = true
    @Published var isSensor: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case number, level, level0, level1, level2, level3, cct, angle, runTime, fadeTime, isAi, isSensor
    }
    
    init() {}
    
    static var scene1Model = GLSceneModel()
    static var scene2Model: GLSceneModel = {
        let model = GLSceneModel()
        model.number = 2
        model.level0 = 100
        model.level1 = 70
        model.level2 = 50
        model.level3 = 0
        model.runTime = 30
        model.fadeTime = 10
        return model
    }()
    static var scene3Model: GLSceneModel = {
        let model = GLSceneModel()
        model.number = 3
        model.level0 = 70
        model.level1 = 50
        model.level2 = 30
        model.level3 = 20
        model.runTime = 300
        model.fadeTime = 60
        return model
    }()
    static var scene4Model: GLSceneModel = {
        let model = GLSceneModel()
        model.number = 4
        model.level0 = 100
        model.level1 = 70
        model.level2 = 50
        model.level3 = 20
        model.runTime = 20
        model.fadeTime = 5
        return model
    }()
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        number = try values.decode(SceneNumber.self, forKey: .number)
        level0 = try values.decode(Double.self, forKey: .level0)
        level1 = try values.decode(Double.self, forKey: .level1)
        level2 = try values.decode(Double.self, forKey: .level2)
        level3 = try values.decode(Double.self, forKey: .level3)
        cct = try values.decode(Double.self, forKey: .cct)
        angle = try values.decode(Double.self, forKey: .angle)
        runTime = try values.decode(Double.self, forKey: .runTime)
        fadeTime = try values.decode(Double.self, forKey: .fadeTime)
        isAi = try values.decode(Bool.self, forKey: .isAi)
        isSensor = try values.decode(Bool.self, forKey: .isSensor)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
        try container.encode(level0, forKey: .level0)
        try container.encode(level1, forKey: .level1)
        try container.encode(level2, forKey: .level2)
        try container.encode(level3, forKey: .level3)
        try container.encode(cct, forKey: .cct)
        try container.encode(angle, forKey: .angle)
        try container.encode(runTime, forKey: .runTime)
        try container.encode(fadeTime, forKey: .fadeTime)
        try container.encode(isAi, forKey: .isAi)
        try container.encode(isSensor, forKey: .isSensor)
    }
}

class GLNodeModel: ObservableObject, Codable {
    @Published var scenes: [SceneNumber: GLSceneModel] = [:]
    @Published var selectedScene: SceneNumber = 0
    
    enum CodingKeys: String, CodingKey {
        case scenes, selectedScene
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        scenes = try values.decode([SceneNumber: GLSceneModel].self, forKey: .scenes)
        selectedScene = try values.decode(SceneNumber.self, forKey: .selectedScene)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scenes, forKey: .scenes)
        try container.encode(selectedScene, forKey: .selectedScene)
    }
}

class GLGroupModel: ObservableObject, Codable {
    @Published var scenes: [SceneNumber: GLSceneModel] = [:]
    @Published var selectedScene: SceneNumber = 0
    
    enum CodingKeys: String, CodingKey {
        case scenes, selectedScene
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        scenes = try values.decode([SceneNumber: GLSceneModel].self, forKey: .scenes)
        selectedScene = try values.decode(SceneNumber.self, forKey: .selectedScene)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scenes, forKey: .scenes)
        try container.encode(selectedScene, forKey: .selectedScene)
    }
    
}


class MessageDetailStore: NSObject, ObservableObject, Codable {
    
    @Published var isOn = false
    
    @Published var isAi: Bool = false
    @Published var isSensor: Bool = false
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
        isOn = try values.decode(Bool.self, forKey: .isOn)
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

class GLDraftModel: ObservableObject, Codable, Hashable {
    
    @Published var name: String = "Draft"
    @Published var store: MessageDetailStore = MessageDetailStore()
    @Published var messageTypes: [MessageType] = []
    
    init(name: String, store: MessageDetailStore, messageTypes: [MessageType]) {
        self.name = name
        self.store = store
        self.messageTypes = messageTypes
    }
    
    enum CodingKeys: String, CodingKey {
        case name, store, messageTypes
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        store = try values.decode(MessageDetailStore.self, forKey: .store)
        messageTypes = try values.decode([MessageType].self, forKey: .messageTypes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(store, forKey: .store)
        try container.encode(messageTypes, forKey: .messageTypes)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(store)
    }
    
    static func == (lhs: GLDraftModel, rhs: GLDraftModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class GLZone: ObservableObject, Codable, Hashable {
    @Published var name: String = "Zone"
    @Published var zone: UInt8 = 0x0
    @Published var store: MessageDetailStore = MessageDetailStore()
    
    init(name: String, zone: UInt8) {
        self.name = name
        self.zone = zone
    }
    
    enum CodingKeys: String, CodingKey {
        case name, zone, store
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
    
    @Published var nodes: [Address: GLNodeModel] = [:]
    @Published var groups: [Address: GLGroupModel] = [:]
    @Published var scenes: [SceneNumber: GLSceneModel] = [:]
    
    @Published var drafts: [GLDraftModel] = []
    @Published var zone: [GLZone] = []
    
    enum CodingKeys: String, CodingKey {
        case nodes, groups, scenes, drafts, zone
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nodes = try values.decode([Address: GLNodeModel].self, forKey: .nodes)
        groups = try values.decode([Address: GLGroupModel].self, forKey: .groups)
        scenes = try values.decode([SceneNumber: GLSceneModel].self, forKey: .scenes)
        drafts = try values.decode([GLDraftModel].self, forKey: .drafts)
        zone = try values.decode([GLZone].self, forKey: .zone)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodes, forKey: .nodes)
        try container.encode(groups, forKey: .groups)
        try container.encode(scenes, forKey: .scenes)
        try container.encode(drafts, forKey: .drafts)
        try container.encode(zone, forKey: .zone)
    }
    
    func reset() {
        nodes.removeAll()
        groups.removeAll()
        scenes.removeAll()
        drafts.removeAll()
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
            GLMeshNetworkModel.instance.groups = model.groups
            GLMeshNetworkModel.instance.nodes = model.nodes
            GLMeshNetworkModel.instance.scenes = model.scenes
            GLMeshNetworkModel.instance.drafts = model.drafts
            GLMeshNetworkModel.instance.zone = model.zone
            print("model load success")
            return true
        }
        return false
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

extension nRFMeshProvision.Scene {
    var model: GLSceneModel? {
        get {
            GLMeshNetworkModel.instance.scenes[number]
        }
        set {
            if let newValue {
                GLMeshNetworkModel.instance.scenes.updateValue(newValue, forKey: number)
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
