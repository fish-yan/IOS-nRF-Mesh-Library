//
//  Node+Extension.swift
//  nRF Mesh
//
//  Created by yan on 2024/7/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import NordicMesh

extension Node {
    var customScenes: [NordicMesh.Scene] {
        scenes.filter { !MeshNetworkManager.defaultSceneAddresses.contains($0.number) }
    }
    
    var onOffModel: Model? {
        models(withSigModelId: .genericOnOffServerModelId).first
    }
    
//    var emergencyModel: Model? {
//        let models = models(withSigModelId: .genericOnOffServerModelId)
//        if models.count >= 2 {
//            return models[1]
//        }
//        return nil
//    }
//
//    var pirModel: Model? {
//        let models = models(withSigModelId: .genericOnOffServerModelId)
//        if models.count >= 3 {
//            return models[2]
//        }
//        return nil
//    }
//
//    var aiModel: Model? {
//        let models = models(withSigModelId: .genericOnOffServerModelId)
//        if models.count >= 4 {
//            return models[3]
//        }
//        return nil
//    }
    
    var levelModel: Model? {
        models(withSigModelId: .genericLevelServerModelId).first
    }
    
    var cctModel: Model? {
        let models = models(withSigModelId: .genericLevelServerModelId)
        if models.count >= 2 {
            return models[1]
        }
        return nil
    }
    
    var angleModel: Model? {
        let models = models(withSigModelId: .genericLevelServerModelId)
        if models.count >= 3 {
            return models[2]
        }
        return nil
    }
    
    var sceneClientModel: Model? {
        primaryElement?.model(withSigModelId: .sceneClientModelId)
    }
    
    var sceneModel: Model? {
        primaryElement?.model(withSigModelId: .sceneServerModelId)
    }
    
    var sceneSetupModel: Model? {
        primaryElement?.model(withSigModelId: .sceneSetupServerModelId)
    }
    
    var vendorModel: Model? {
        primaryElement?.models.first(where: { !$0.isBluetoothSIGAssigned })
    }
    
    var usefulModels: [Model] {
        return [
            onOffModel,
            levelModel,
            cctModel,
            angleModel,
            sceneClientModel,
            sceneModel,
            sceneSetupModel,
            vendorModel
        ].compactMap { $0 }
    }
}

extension Node {
    var productType: GLProductType? {
        if let productIdentifier {
            return GLProductType(rawValue: productIdentifier)
        }
        return nil
    }
}

extension Node: Identifiable, Hashable {
    public var id: UUID { UUID() }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(primaryUnicastAddress)
    }
}
