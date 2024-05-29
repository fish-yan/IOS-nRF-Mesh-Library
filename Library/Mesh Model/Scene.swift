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

import Foundation


public enum DefaultSceneMode {
    public var rawValue: SceneNumber {
        switch self {
        case .standard: 1
        case .eco: 2
        case .comfort: 3
        case .display: 4
        case .other(let number): number
        }
    }
    
    case standard
    case eco
    case comfort
    case display
    case other(number: SceneNumber)
        
    public var name: String {
        switch self {
        case .standard: "Standard Mode"
        case .eco: "Eco Mode"
        case .comfort: "Comfort Mode"
        case .display: "Display Mode"
        case .other(let number): "Custom Mode \(number)"
        }
    }
    
    public var detail: String {
        switch self {
        case .standard: "Suitable for daily use scenarios"
        case .eco: "Reduced energy consumption"
        case .comfort: "Comfortable lighting experience"
        case .display: "Demonstrate functional use"
        default: "Personalised Lighting Modes"
        }
    }
    
    public init(rawValue: SceneNumber) {
        switch rawValue {
        case 1: self = .standard
        case 2: self = .eco
        case 3: self = .comfort
        case 4: self = .display
        default: self = .other(number: rawValue)
        }
    }
}


/// A Scene represents a set of states stored with a Scene Number.
///
/// A Scene is identified by a ``SceneNumber`` and may have a
/// human-readable name associated.
///
/// A Node having a Scene Server model can store the states of other
/// models and restore them on demand.
///
/// A Node with a Scene Client can recall Scenes on other Nodes.
///
/// Use ``Scene/elements`` to get list of ``Element``s with
/// the given Scene in their Scene Register.
public class Scene: Codable {
    internal weak var meshNetwork: MeshNetwork?
    
    /// Scene number.
    public let number: SceneNumber
    /// UTF-8 human-readable name of the Scene.
    public var name: String
    public var detail: String
    /// Addresses of Elements whose Scene Register state contains this Scene.
    public internal(set) var addresses: [Address]
    
    internal init(_ number: SceneNumber, name: String = "", detail: String = "") {
        if name.isEmpty {
            let sceneCase = DefaultSceneMode(rawValue: number)
            self.name = sceneCase.name
            self.detail = sceneCase.detail
        } else {
            self.name = name
            self.detail = detail
        }
        self.number = number
        self.addresses = []
    }
    
    internal init(copy scene: Scene, andTruncateTo nodes: [Node]) {
        self.number = scene.number
        self.name = scene.name
        self.detail = scene.detail
        self.addresses = scene.addresses
            .filter { address in nodes.contains { node in node.contains(elementWithAddress: address) } }
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: CodingKey {
        case scene // 3.0-beta1 was using 'scene' instead of 'number'.
        case number
        case name
        case detail
        case addresses
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sceneNumberString  = try container.decode(String.self, forKey: .number, or: .scene)
        guard let number = SceneNumber(hex: sceneNumberString) else {
            throw DecodingError.dataCorruptedError(forKey: .number, in: container,
                                                   debugDescription: "Scene number must be 4-character hexadecimal string.")
        }
        guard number.isValidSceneNumber else {
            throw DecodingError.dataCorruptedError(forKey: .number, in: container,
                                                   debugDescription: "Invalid scene number.")
        }
        self.number = number
        self.name = try container.decode(String.self, forKey: .name)
        self.detail = (try? container.decode(String.self, forKey: .detail)) ?? "Personalised Lighting Modes"
        self.addresses = []
        let addressesStrings = try container.decode([String].self, forKey: .addresses)
        try addressesStrings.forEach {
            guard let address = Address(hex: $0) else {
                throw DecodingError.dataCorruptedError(forKey: .addresses, in: container,
                                                       debugDescription: "Address must be 4-character hexadecimal.")
            }
            guard address.isUnicast else {
                throw DecodingError.dataCorruptedError(forKey: .addresses, in: container,
                                                       debugDescription: "Address must be of unicast type.")
            }
            self.addresses.append(address)
        }
        self.addresses.sort()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number.hex, forKey: .number)
        try container.encode(name, forKey: .name)
        try container.encode(detail, forKey: .detail)
        try container.encode(addresses.map { $0.hex }, forKey: .addresses)
    }
}

public extension Scene {
    
    /// Adds the Unicast Address to the Scene object.
    ///
    /// - parameter address: The Unicast Address of an Element with Scene Server model
    ///                      that is confirmed to have the Scene in its Scene Register.
    func add(address: Address) {
        guard address.isUnicast && !addresses.contains(address) else {
            return
        }
        addresses.append(address)
        addresses.sort()
        meshNetwork?.timestamp = Date()
    }
    
    /// Removes the Unicast Address from the Scene object.
    ///
    /// - parameter address: The Unicast Address of an Element with Scene Server model
    ///                      that may have the Scene in its Scene Register.
    func remove(address: Address) {
        guard address.isUnicast,
              let index = addresses.firstIndex(of: address) else {
            return
        }
        addresses.remove(at: index)
        meshNetwork?.timestamp = Date()
    }
    
    /// Removes all Unicast Addresses assigned to the given Node from the
    /// Scene object.
    ///
    /// - parameter node: The Node that is may have the Scene in any of
    ///                   its Scene Registers.
    func remove(node: Node) {
        node.elements.forEach { element in
            if let index = addresses.firstIndex(of: element.unicastAddress) {
                addresses.remove(at: index)
                meshNetwork?.timestamp = Date()
            }
        }        
    }
    
}

extension Scene: Equatable, Hashable {
    
    public static func == (lhs: Scene, rhs: Scene) -> Bool {
        return lhs.number == rhs.number
            && lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(number)
    }
    
}
