/*
* Copyright (c) 2019, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit
import os.log
import nRFMeshProvision
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var meshNetworkManager: MeshNetworkManager!
    var connection: NetworkConnection!
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create the main MeshNetworkManager instance and customize
        // configuration values.
        meshNetworkManager = MeshNetworkManager()
        
        // Configure network parameters using one of the following examples:
        /*
        // Default configuration.
        meshNetworkManager.networkParameters = .default
        */
        
        // Verbose configuration.
        meshNetworkManager.networkParameters = .basic { parameters in
            parameters.setDefaultTtl(5)
            // Configure SAR Receiver properties
            parameters.discardIncompleteSegmentedMessages(after: 10.0)
            parameters.transmitSegmentAcknowledgmentMessage(
                usingSegmentReceptionInterval: 0.06,
                multipliedByMinimumDelayIncrement: 2.5)
            parameters.retransmitSegmentAcknowledgmentMessages(
                exactly: 1, timesWhenNumberOfSegmentsIsGreaterThan: 3)
            // Configure SAR Transmitter properties
            parameters.transmitSegments(withInterval: 0.06)
            parameters.retransmitUnacknowledgedSegmentsToUnicastAddress(
                atMost: 2, timesAndWithoutProgress: 2,
                timesWithRetransmissionInterval: 0.200, andIncrement: 2.5)
            parameters.retransmitAllSegmentsToGroupAddress(exactly: 3, timesWithInterval: 0.250)
            
            // Note: The values below are different from the default ones.
            
            // Configure message configuration
            parameters.retransmitAcknowledgedMessage(after: 4.2)
            // As the interval has been increased, the timeout can be adjusted.
            // The acknowledged message will be repeated after 4.2 seconds,
            // 12.6 seconds (4.2 + 4.2 * 2), and 29.4 seconds (4.2 + 4.2 * 2 + 4.2 * 4).
            // Then, leave 10 seconds for until the incomplete message times out.
            parameters.discardAcknowledgedMessages(after: 40.0)
        }
        
        /*
        // Advanced configuration.
        meshNetworkManager.networkParameters = .advanced { parameters in
            parameters.defaultTtl = 5
            // Configure SAR Receiver properties
            parameters.sarDiscardTimeout = 0b0001
            parameters.sarAcknowledgmentDelayIncrement = 0b001
            parameters.sarReceiverSegmentIntervalStep = 0b101
            parameters.sarSegmentsThreshold = 0b00011
            parameters.sarAcknowledgmentRetransmissionsCount = 0b00
            // Configure SAR Transmitter properties
            parameters.sarSegmentIntervalStep = 0b0101
            parameters.sarUnicastRetransmissionsCount = 0b0111
            parameters.sarUnicastRetransmissionsWithoutProgressCount = 0b0010
            parameters.sarUnicastRetransmissionsIntervalStep = 0b0111
            parameters.sarUnicastRetransmissionsIntervalIncrement = 0b0001
            parameters.sarMulticastRetransmissionsCount = 0b0010
            parameters.sarMulticastRetransmissionsIntervalStep = 0b1001
            // Configure acknowledged message timeouts
            parameters.acknowledgmentMessageInterval = 4.2
            // As the interval has been increased, the timeout can be adjusted.
            // The acknowledged message will be repeated after 4.2 seconds,
            // 12.6 seconds (4.2 + 4.2 * 2), and 29.4 seconds (4.2 + 4.2 * 2 + 4.2 * 4).
            // Then, leave 10 seconds for until the incomplete message times out.
            parameters.acknowledgmentMessageTimeout = 40.0
        }
        */
        meshNetworkManager.logger = self
        
        // Try loading the saved configuration.
        if meshNetworkManager.loadAll() {
            meshNetworkDidChange()
        } else {
            createNewMeshNetwork()
        }
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.overrideUserInterfaceStyle = .light
        let rootVC = UIHostingController(rootView: RootView())
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        
        return true
    }
    
    /// This method creates a new mesh network with a default name and a
    /// single Provisioner.
    ///
    /// When done, calls ``AppDelegate/meshNetworkDidChange()``.
    ///
    /// - returns: The newly created mesh network.
    @discardableResult
    func createNewMeshNetwork() -> MeshNetwork {
        let provisioner = Provisioner(name: UIDevice.current.name,
                                      allocatedUnicastRange: [AddressRange(0x0001...0x199A)],
                                      allocatedGroupRange:   [AddressRange(0xD000...0xDC9A)],
                                      allocatedSceneRange:   [SceneRange(0x0001...0x3333)])
        let network = meshNetworkManager.createNewMeshNetwork(withName: "nRF Mesh Network", by: provisioner)
        _ = meshNetworkManager.save()
        
        meshNetworkDidChange()
        return network
    }
    
    /// Sets up the local Elements and reinitializes the ``NetworkConnection``
    /// so that it starts scanning for devices advertising the new Network ID.
    func meshNetworkDidChange() {
        connection?.close()
        
        let meshNetwork = meshNetworkManager.meshNetwork!

        // Generic Default Transition Time Server model:
        let defaultTransitionTimeServerDelegate = GenericDefaultTransitionTimeServerDelegate(meshNetwork)
        // Scene Server and Scene Setup Server models:
        let sceneServer = SceneServerDelegate(meshNetwork,
                                              defaultTransitionTimeServer: defaultTransitionTimeServerDelegate)
        let sceneSetupServer = SceneSetupServerDelegate(server: sceneServer)
        
        // Set up local Elements on the phone.
        let element0 = Element(name: "Primary Element", location: .first, models: [
            // Scene Server and Scene Setup Server models (client is added automatically):
            Model(sigModelId: .sceneServerModelId, delegate: sceneServer),
            Model(sigModelId: .sceneSetupServerModelId, delegate: sceneSetupServer),
            // Sensor Client model:
            Model(sigModelId: .sensorClientModelId, delegate: SensorClientDelegate()),
            // Generic Power OnOff Client model:
            Model(sigModelId: .genericPowerOnOffClientModelId, delegate: GenericPowerOnOffClientDelegate()),
            // Generic Default Transition Time Server model:
            Model(sigModelId: .genericDefaultTransitionTimeServerModelId,
                  delegate: defaultTransitionTimeServerDelegate),
            Model(sigModelId: .genericDefaultTransitionTimeClientModelId,
                  delegate: GenericDefaultTransitionTimeClientDelegate()),
            // 4 generic models defined by Bluetooth SIG:
            Model(sigModelId: .genericOnOffServerModelId,
                  delegate: GenericOnOffServerDelegate(meshNetwork,
                                                       defaultTransitionTimeServer: defaultTransitionTimeServerDelegate,
                                                       elementIndex: 0)),
            Model(sigModelId: .genericLevelServerModelId,
                  delegate: GenericLevelServerDelegate(meshNetwork,
                                                       defaultTransitionTimeServer: defaultTransitionTimeServerDelegate,
                                                       elementIndex: 0)),
            Model(sigModelId: .genericOnOffClientModelId, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: .genericLevelClientModelId, delegate: GenericLevelClientDelegate()),
            // A simple vendor model:
            Model(vendorModelId: .simpleOnOffClientModelId,
                  companyId: .nordicSemiconductorCompanyId,
                  delegate: SimpleOnOffClientDelegate())
        ])
        let element1 = Element(name: "Secondary Element", location: .second, models: [
            Model(sigModelId: .genericOnOffServerModelId,
                  delegate: GenericOnOffServerDelegate(meshNetwork,
                                                       defaultTransitionTimeServer: defaultTransitionTimeServerDelegate,
                                                       elementIndex: 1)),
            Model(sigModelId: .genericLevelServerModelId,
                  delegate: GenericLevelServerDelegate(meshNetwork,
                                                       defaultTransitionTimeServer: defaultTransitionTimeServerDelegate,
                                                       elementIndex: 1)),
            Model(sigModelId: .genericOnOffClientModelId, delegate: GenericOnOffClientDelegate()),
            Model(sigModelId: .genericLevelClientModelId, delegate: GenericLevelClientDelegate())
        ])
        meshNetworkManager.localElements = [element0, element1]
        
        connection = NetworkConnection(to: meshNetwork)
        connection!.dataDelegate = meshNetworkManager
        connection!.logger = self
        meshNetworkManager.transmitter = connection
        connection!.open()
        
        createDefaultApplicationKey()
        createDefaultGroup()
        createDefaultScene()
        addDefaultScene()
        addDefaultGroup()
        addDefaultZone()
    }
    
    func createDefaultApplicationKey() {
        let network = meshNetworkManager.meshNetwork!
        let keys = network.applicationKeys
        guard keys.isEmpty else { return }
        let keyName = "App Key 1"
        let keyIndex: KeyIndex = 0
        let newKey = Data.random128BitKey()
        let key = try! network.add(applicationKey: newKey, withIndex: keyIndex, name: keyName)
        if let netowrkKey = network.networkKeys.first {
            try? key.bind(to: netowrkKey)
        }
        let _ = meshNetworkManager.save()
    }
    
    func createDefaultGroup() {
        let network = meshNetworkManager.meshNetwork!
        let defaultAddress = MeshNetworkManager.defaultGroupAddresses
        let unAddaddress = defaultAddress.filter { add in !network.groups.contains(where: { $0.address.address == add })}
        if unAddaddress.isEmpty { return }
        unAddaddress.forEach {
            let group = try! Group(name: String($0, radix: 16, uppercase: true), address: $0)
            try? network.add(group: group)
        }
        let _ = meshNetworkManager.save()
    }
    
    func createDefaultScene() {
        let network = meshNetworkManager.meshNetwork!
        let defaultScenes: [SceneNumber] = MeshNetworkManager.defaultSceneAddresses
        let unAddScene = defaultScenes.filter {number in !network.scenes.contains(where: { $0.number == number }) }
        unAddScene.forEach { number in
            try? network.add(scene: number, name: "Scene \(number)")
        }
        let _ = meshNetworkManager.save()
    }
    
    func addDefaultScene() {
        guard let meshNetwork = MeshNetworkManager.instance.meshNetwork else {
            return
        }
        let nodes = meshNetwork.nodes.filter { !$0.isProvisioner }
        let defaultScenes: [SceneNumber] = MeshNetworkManager.defaultSceneAddresses
        nodes.forEach { node in
            let address = node.primaryUnicastAddress
            for scene in meshNetwork.scenes where defaultScenes.contains(scene.number) {
                scene.add(address: address)
            }
        }
        _ = MeshNetworkManager.instance.save()
    }
    
    func addDefaultGroup() {
        guard let meshNetwork = MeshNetworkManager.instance.meshNetwork else {
            return
        }
        let defaultAddress = MeshNetworkManager.defaultGroupAddresses
        let nodes = meshNetwork.nodes.filter { !$0.isProvisioner }
        nodes.forEach { node in
            node.usefulModels.forEach { model in
                for group in meshNetwork.groups where defaultAddress.contains(group.address.address) {
                    model.subscribe(to: group)
                }
            }
        }
        _ = MeshNetworkManager.instance.save()
    }
    
    func addDefaultZone() {
        let zones = GLMeshNetworkModel.instance.zone
        if zones.isEmpty {
            let all = createZone(name: "All", zone: 0x0)
            GLMeshNetworkModel.instance.zone.append(all)
            MeshNetworkManager.instance.saveModel()
        }
    }
    
    func createZone(name: String, zone: UInt8) -> GLZone {
        let meshNetwork = MeshNetworkManager.instance.meshNetwork!
        let zone = GLZone(name: name, zone: zone)
        let nodes = meshNetwork.nodes
        let scenes = nodes.flatMap({$0.scenes}).uniqued()
        scenes.forEach { scene in
            switch scene.number {
            case 1:
                scene.name = "Standard Mode"
                scene.detail = "Suitable for daily use scenarios"
            case 2:
                scene.name = "Eco Mode"
                scene.detail = "Reduced energy consumption"
            case 3:
                scene.name = "Comfort Mode"
                scene.detail = "Comfortable lighting experience"
            case 4:
                scene.name = "Display Mode"
                scene.detail = "Demonstrate functional use"
            default:
                scene.name = "Custom Mode \(scene.number)"
                scene.detail = "Personalised Lighting Modes"
            }
        }
        zone.nodeAddresses = nodes.map({$0.primaryUnicastAddress})
        return zone
    }
}

// MARK: - Logger

extension AppDelegate: LoggerDelegate {
    
    func log(message: String, ofCategory category: LogCategory, withLevel level: LogLevel) {
        if #available(iOS 10.0, *) {
            os_log("%{public}@", log: category.log, type: level.type, message)
        } else {
            NSLog("%@", message)
        }
    }
    
}

extension LogLevel {
    
    /// Mapping from mesh log levels to system log types.
    var type: OSLogType {
        switch self {
        case .debug:       return .debug
        case .verbose:     return .debug
        case .info:        return .info
        case .application: return .default
        case .warning:     return .error
        case .error:       return .fault
        }
    }
    
}

extension LogCategory {
    
    var log: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: rawValue)
    }
    
}
