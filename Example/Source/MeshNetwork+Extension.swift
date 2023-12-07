//
//  MeshNetwork+Extension.swift
//  nRF Mesh
//
//  Created by yan on 2023/11/20.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

extension MeshNetworkManager {
    
    static var instance: MeshNetworkManager {
        if Thread.isMainThread {
            return (UIApplication.shared.delegate as! AppDelegate).meshNetworkManager
        } else {
            return DispatchQueue.main.sync {
                return (UIApplication.shared.delegate as! AppDelegate).meshNetworkManager
            }
        }
    }
    
    static var bearer: NetworkConnection! {
        if Thread.isMainThread {
            return (UIApplication.shared.delegate as! AppDelegate).connection
        } else {
            return DispatchQueue.main.sync {
                return (UIApplication.shared.delegate as! AppDelegate).connection
            }
        }
    }
    
    @discardableResult
    func send(_ message: VendorMessage,
              from localElement: Element? = nil, to model: Model,
              withTtl initialTtl: UInt8? = nil,
              completion: ((Result<Void, Error>) -> ())? = nil) throws -> MessageHandle {
        guard let element = model.parentElement else {
            print("Error: Element does not belong to a Node")
            throw AccessError.invalidDestination
        }
        guard let meshNetwork = meshNetwork,
              let applicationKey = meshNetwork.applicationKey else {
            print("Error: Model is not bound to any Application Key")
            throw AccessError.modelNotBoundToAppKey
        }
        return try send(message, from: localElement, to: MeshAddress(element.unicastAddress),
                        withTtl: initialTtl, using: applicationKey,
                        completion: completion)
    }
    
    func send(_ message: MeshMessage, to model: Model) throws -> MessageHandle {
        guard let element = model.parentElement else {
            print("Error: Element does not belong to a Node")
            throw AccessError.invalidDestination
        }
        guard let meshNetwork = meshNetwork,
              let applicationKey = meshNetwork.applicationKey else {
            print("Error: Model is not bound to any Application Key")
            throw AccessError.modelNotBoundToAppKey
        }
        return try send(message, from: nil, to: MeshAddress(element.unicastAddress),
                        withTtl: nil, using: applicationKey,
                        completion: nil)
    }
    
    @discardableResult
    func send(_ message: MeshMessage,
              from localElement: Element? = nil, to group: Group,
              withTtl initialTtl: UInt8? = nil,
              completion: ((Result<Void, Error>) -> ())? = nil) throws -> MessageHandle {
        guard let meshNetwork = meshNetwork,
              let applicationKey = meshNetwork.applicationKey else {
            print("Error: Model is not bound to any Application Key")
            throw AccessError.modelNotBoundToAppKey
        }
        return try send(message, from: localElement, to: group.address,
                        withTtl: initialTtl, using: applicationKey,
                        completion: completion)
    }
    
    static var defaultGroupAddresses: [Address] = [0xD000, 0xD001, 0xD002, 0xD003, 0xD004, 0xD005, 0xD006]
    static let defaultSceneAddresses: [SceneNumber] = [1, 2, 3, 4]
}

extension MeshNetwork {
    var applicationKey: ApplicationKey? {
        if Thread.isMainThread {
            return applicationKeys.first
        } else {
            return DispatchQueue.main.sync {
                return applicationKeys.first
            }
        }
    }
    
    var customGroups: [nRFMeshProvision.Group] {
        let defaultAddress = MeshNetworkManager.defaultGroupAddresses
        return groups.filter { !defaultAddress.contains($0.address.address) }
    }
    
    var customScenes: [nRFMeshProvision.Scene] {
        scenes.filter { !MeshNetworkManager.defaultSceneAddresses.contains($0.number) }
    }
}

extension Node {
    var customScenes: [nRFMeshProvision.Scene] {
        scenes.filter { !MeshNetworkManager.defaultSceneAddresses.contains($0.number) }
    }
    
    var onOffModel: Model? {
        models(withSigModelId: .genericOnOffServerModelId).first
    }
    
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
        return [onOffModel, levelModel, cctModel, vendorModel].compactMap { $0 }
    }
}

extension Element {
    func filteredModels() -> [Model] {
        let filterIds: [UInt16] = [.configurationClientModelId,
                                   .genericOnOffServerModelId,
                                   .genericOnOffClientModelId,
                                   .genericLevelServerModelId,
                                   .genericLevelClientModelId]
        return self.models.filter { filterIds.contains($0.modelIdentifier) || !$0.isBluetoothSIGAssigned}
    }
}

public extension Group {
    var scenes: [nRFMeshProvision.Scene] {
        guard let applicationKey = MeshNetworkManager.instance.meshNetwork?.applicationKey else {
            return []
        }
        return scenes(onModelsBoundTo: applicationKey)
    }
    
    var customScenes: [nRFMeshProvision.Scene] {
        scenes.filter { !MeshNetworkManager.defaultSceneAddresses.contains($0.number) }
    }
}
