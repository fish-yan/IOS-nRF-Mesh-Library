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

public struct Publish: Codable {
    
    /// The object is used to describe the number of times a message is
    /// published and the interval between retransmissions of the published
    /// message.
    public struct Retransmit: Codable {
        /// Number of retransmissions for network messages.
        /// The value is in range from 0 to 7, where 0 means no retransmissions.
        public let count: UInt8
        /// The interval (in milliseconds) between retransmissions (50...1600 with step 50).
        public let interval: UInt16
        /// Retransmission steps, from 0 to 31. Use `interval` to get the interval in ms.
        public var steps: UInt8 {
            return UInt8((interval / 50) - 1)
        }
        
        internal init() {
            count = 0
            interval = 50
        }
        
        public init(publishRetransmitCount: UInt8, intervalSteps: UInt8) {
            count    = publishRetransmitCount
            // Interval is in 50 ms steps.
            interval = UInt16(intervalSteps + 1) * 50 // ms
        }
    }
    
    public struct Period: Codable {
        /// The number of steps, in range 0...63.
        public let numberOfSteps: UInt8
        /// The resolution of the number of steps.
        public let resolution: StepResolution
        /// The interval between subsequent publications in seconds.
        public let interval: TimeInterval
        
        init() {
            self.numberOfSteps = 0
            self.resolution = .hundredsOfMilliseconds
            self.interval = 0.0
        }
        
        init(steps: UInt8, resolution: StepResolution) {
            self.numberOfSteps = steps
            self.resolution = resolution
            self.interval = TimeInterval(resolution.toMilliseconds(steps: steps)) / 1000.0
        }
        
        // MARK: - Codable
        
        private enum CodingKeys: String, CodingKey {
            case numberOfSteps
            case resolution
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let steps = try container.decode(UInt8.self, forKey: .numberOfSteps)
            guard steps <= 63 else {
                throw DecodingError.dataCorruptedError(forKey: .numberOfSteps, in: container,
                                                       debugDescription: "Number of steps must be in range 0 to 63.")
            }
            let milliseconds = try container.decode(Int.self, forKey: .resolution)
            guard let resolution = StepResolution(from: milliseconds) else {
                throw DecodingError.dataCorruptedError(forKey: .resolution, in: container,
                                                       debugDescription: "Unsupported resolution value: \(milliseconds). "
                                                                       + "The allowed values are: 100, 1000, 10000, and 600000.")
            }
            self.numberOfSteps = steps
            self.resolution = resolution
            self.interval = TimeInterval(resolution.toMilliseconds(steps: steps)) / 1000.0
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(numberOfSteps, forKey: .numberOfSteps)
            try container.encode(resolution.toMilliseconds(steps: 1), forKey: .resolution)
        }
    }
    
    /// Publication address for the Model. It's 4 or 32-character long
    /// hexadecimal string.
    private let address: String
    /// Publication address for the model.
    public var publicationAddress: MeshAddress {
        // Warning: assuming hex address is valid!
        return MeshAddress(hex: address)!
    }
    /// An Application Key index, indicating which Applicaiton Key to
    /// use for the publication.
    public let index: KeyIndex
    /// An integer from 0 to 127 that represents the Time To Live (TTL)
    /// value for the outgoing publish message. 255 means default TTL value.
    public let ttl: UInt8
    /// The interval between subsequent publications.
    public let period: Period
    /// An integer 0 o 1 that represents whether master security
    /// (0) materials or friendship security material (1) are used.
    internal let credentials: Int
    /// The object describes the number of times a message is published and the
    /// interval between retransmissions of the published message.
    public internal(set) var retransmit: Retransmit
    
    /// Creates an instance of Publish object.
    ///
    /// - parameters:
    ///   - destination: The publication address.
    ///   - applicationKey: The Application Key that will be used to send messages.
    ///   - friendshipCredentialsFlag: `True`, to use Friendship Security Material,
    ///                                `false` to use Master Security Material.
    ///   - ttl: Time to live. Use 0xFF to use Node's default TTL.
    ///   - periodSteps: Period steps, together with `periodResolution` are used to
    ///                  calculate period interval. Value can be in range 0...63.
    ///                  Value 0 disables periodic publishing.
    ///   - periodResolution: The period resolution, used to calculate interval.
    ///                       Use `._100_milliseconds` when periodic publishing is
    ///                       disabled.
    ///   - retransmit: The retransmission data. See `Retransmit` for details.
    public init(to destination: MeshAddress, using applicationKey: ApplicationKey,
                usingFriendshipMaterial friendshipCredentialsFlag: Bool, ttl: UInt8,
                periodSteps: UInt8, periodResolution: StepResolution, retransmit: Retransmit) {
        self.init(to: destination, usingApplicationKeyWithKeyIndex: applicationKey.index,
                  usingFriendshipMaterial: friendshipCredentialsFlag, ttl: ttl,
                  periodSteps: periodSteps, periodResolution: periodResolution,
                  retransmit: retransmit)
    }
    
    internal init(to destination: MeshAddress, usingApplicationKeyWithKeyIndex index: KeyIndex,
                usingFriendshipMaterial friendshipCredentialsFlag: Bool, ttl: UInt8,
                periodSteps: UInt8, periodResolution: StepResolution, retransmit: Retransmit) {
        self.address = destination.hex
        self.index = index
        self.credentials = friendshipCredentialsFlag ? 1 : 0
        self.ttl = ttl
        self.period = Period(steps: periodSteps, resolution: periodResolution)
        self.retransmit = retransmit
    }
    
    /// This initializer should be used to remove the publication from a Model.
    internal init() {
        self.address = "0000"
        self.index = 0
        self.credentials = 0
        self.ttl = 0
        self.period = Period()
        self.retransmit = Retransmit()
    }
    
    internal init(to destination: String, withKeyIndex keyIndex: KeyIndex,
                  friendshipCredentialsFlag: Int, ttl: UInt8,
                  period: Period, retransmit: Retransmit) {
        self.address = destination
        self.index = keyIndex
        self.credentials = friendshipCredentialsFlag
        self.ttl = ttl
        self.period = period
        self.retransmit = retransmit
    }
    
    // MARK: - Codable
    
    private enum CodingKeys: String, CodingKey {
        case address
        case index
        case ttl
        case period
        case credentials
        case retransmit
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let publishAddressAsString = try container.decode(String.self, forKey: .address)
        guard let _ = MeshAddress(hex: publishAddressAsString) else {
            throw DecodingError.dataCorruptedError(forKey: .address, in: container,
                                                   debugDescription: "Address must be 4-character hexadecimal string or UUID.")
        }
        self.address = publishAddressAsString
        self.index = try container.decode(KeyIndex.self, forKey: .index)
        let ttl = try container.decode(UInt8.self, forKey: .ttl)
        guard ttl <= 127 || ttl == 255 else {
            throw DecodingError.dataCorruptedError(forKey: .ttl, in: container,
                                                   debugDescription: "TTL must be in range 0-127 or 255.")
        }
        self.ttl = ttl
        
        // Period has changed from number of milliseconds, to an object
        // containing number of steps and the resolution in version 3.0.
        let millisecondsToPeriodConverter: (Int) throws -> Period = { milliseconds in
            switch milliseconds {
            case let value where value % 600000 == 0:
                return Period(steps: UInt8(value / 600000), resolution: .tensOfMinutes)
            case let value where value % 10000 == 0:
                return Period(steps: UInt8(value / 10000), resolution: .tensOfSeconds)
            case let value where value % 1000 == 0:
                return Period(steps: UInt8(value / 1000), resolution: .seconds)
            case let value where value % 100 == 0:
                return Period(steps: UInt8(value / 100), resolution: .hundredsOfMilliseconds)
            default:
                throw DecodingError.dataCorruptedError(forKey: .period, in: container,
                                                       debugDescription: "Unsupported period value: \(milliseconds).")
            }
        }
        self.period = try container.decode(Period.self, forKey: .period,
                                           orConvert: Int.self, forKey: .period,
                                           using: millisecondsToPeriodConverter)
        
        let flag = try container.decode(Int.self, forKey: .credentials)
        guard flag == 0 || flag == 1 else {
            throw DecodingError.dataCorruptedError(forKey: .credentials, in: container,
                                                   debugDescription: "Credentials must be 0 or 1.")
        }
        self.credentials = flag
        self.retransmit = try container.decode(Retransmit.self, forKey: .retransmit)
        guard retransmit.count <= 7 else {
            throw DecodingError.dataCorruptedError(forKey: .retransmit, in: container,
                                                   debugDescription: "Retransmit count must be in range 0-7.")
        }
        guard retransmit.interval >= 50 &&
              retransmit.interval <= 1600 &&
            (retransmit.interval % 50) == 0 else {
            throw DecodingError.dataCorruptedError(forKey: .retransmit, in: container,
                                                   debugDescription: "Retransmit interval must be in range 50-1600 ms in 50 ms steps.")
        }
    }
    
    /// This method tries to decode the publication period using the legacy schema,
    /// where it was stored as number of milliseconds, instead of steps and resolution
    /// separately.
    ///
    /// - parameter container: The decoding container to read from.
    /// - returns: The Period object.
    /// - throws: Data Corrupted Error when the decoded value is invalid.
    private static func legacyDecodePeriod(from container: KeyedDecodingContainer<CodingKeys>) throws -> Period {
        let period = try container.decode(Int.self, forKey: .period)
        switch period {
        case let period where period % 600000 == 0:
            return Period(steps: UInt8(period / 600000), resolution: .tensOfMinutes)
        case let period where period % 10000 == 0:
            return Period(steps: UInt8(period / 10000), resolution: .tensOfSeconds)
        case let period where period % 1000 == 0:
            return Period(steps: UInt8(period / 1000), resolution: .seconds)
        case let period where period % 100 == 0:
            return Period(steps: UInt8(period / 100), resolution: .hundredsOfMilliseconds)
        default:
            throw DecodingError.dataCorruptedError(forKey: .period, in: container,
                                                   debugDescription: "Unsupported period value: \(period).")
        }
    }
}

public extension Publish {
    
    /// Whether the publication should be cancelled.
    var isCancel: Bool {
        return address == "0000"
    }
    
    /// Returns whether master security materials are used.
    var isUsingMasterSecurityMaterial: Bool {
        return credentials == 0
    }
    
    /// Returns whether friendship security materials are used.
    var isUsingFriendshipSecurityMaterial: Bool {
        return credentials == 1
    }
    
}

internal extension Publish {
    
    /// Creates a copy of the Publish object, but replaces the address
    /// with the given one. This method should be used to fill the virtual
    /// label after a ConfigModelPublicationStatus has been received.
    func withAddress(address: MeshAddress) -> Publish {
        return Publish(to: address.hex, withKeyIndex: index,
                       friendshipCredentialsFlag: credentials, ttl: ttl,
                       period: period,
                       retransmit: retransmit)
    }
    
}

extension Publish: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        if address == "0000" {
            return "Disabled"
        }
        return "\(publicationAddress) using App Key Index: \(index), ttl: \(ttl), flag: \(isUsingFriendshipSecurityMaterial), period: \(period), retransmit: \(retransmit)"
    }
    
}

extension Publish.Retransmit: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        if count == 0 {
            return "Disabled"
        }
        return "\(count) times every \(interval) ms"
    }
    
}

extension Publish.Period: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        if numberOfSteps == 0 {
            return "Disabled"
        }
        
        let value = Int(numberOfSteps)
        
        switch resolution {
        case .hundredsOfMilliseconds where numberOfSteps < 10:
            return "\(value * 100) ms"
        case .hundredsOfMilliseconds where numberOfSteps == 10:
            return "1 sec"
        case .hundredsOfMilliseconds:
            return "\(value / 10).\(value % 10) sec"
            
        case .seconds where numberOfSteps < 60:
            return "\(value) sec"
        case .seconds where numberOfSteps == 60:
            return "1 min"
        case .seconds:
            return "1 min \(value - 60) sec"
            
        case .tensOfSeconds where numberOfSteps < 6:
            return "\(value * 10) sec"
        case .tensOfSeconds where numberOfSteps % 6 == 0:
            return "\(value / 6) min"
        case .tensOfSeconds:
            return "\(value / 6) min \(value % 6 * 10) sec"
            
        case .tensOfMinutes where numberOfSteps < 6:
            return "\(value * 10) min"
        case .tensOfMinutes where numberOfSteps % 6 == 0:
            return "\(value / 6) h"
        case .tensOfMinutes:
            return "\(value / 6) h \(value % 6 * 10) min"
        }
    }
    
}
