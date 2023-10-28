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
    
}

class GLGroupModel: ObservableObject, Codable {
    
}

class GLMeshNetworkModel: ObservableObject, Codable {
    static let instance: GLMeshNetworkModel = GLMeshNetworkModel()
    private init() { }
    
    @Published var nodes: [Address: GLNodeModel] = [:]
    @Published var groups: [Address: GLGroupModel] = [:]
    @Published var scenes: [SceneNumber: GLSceneModel] = [:]
    @Published var selectedScene: SceneNumber = 0
    
    enum CodingKeys: String, CodingKey {
        case nodes, groups, scenes, selectedScene
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        nodes = try values.decode([Address: GLNodeModel].self, forKey: .nodes)
        groups = try values.decode([Address: GLGroupModel].self, forKey: .groups)
        scenes = try values.decode([SceneNumber: GLSceneModel].self, forKey: .scenes)
        selectedScene = try values.decode(SceneNumber.self, forKey: .selectedScene)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nodes, forKey: .nodes)
        try container.encode(groups, forKey: .groups)
        try container.encode(scenes, forKey: .scenes)
        try container.encode(selectedScene, forKey: .selectedScene)
    }
}
private let storage: Storage = LocalStorage(fileName: "GLModel.json")
extension MeshNetworkManager {
    
    @discardableResult
    func loadAll() -> Bool {
        let success = (try? load()) ?? false
        let isModelLoaded = loadModel()
        return success && isModelLoaded
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
        return success && isModelSaved
    }
    
    @discardableResult
    func saveModel() -> Bool {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .withoutEscapingSlashes
        
        let data = try! encoder.encode(GLMeshNetworkModel.instance)
        return storage.save(data)
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
