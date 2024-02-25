//
//  MeshMessageDelegate.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/14.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import nRFMeshProvision

class MeshMessageManager {
    private var debouncer = Debouncer(interval: 100)
    private var isSending = false
    private var messageHandle: MessageHandle?
    private var completion: () -> Void = { }
    var delegate: MeshMessageDelegate? {
        didSet {
            MeshNetworkManager.instance.delegate = self
        }
    }
    
    private var messageQueue = [MessageAction]()
    
    private func sendNext() {
        if isSending {
            return
        }
        guard let messageAction = messageQueue.first else {
            isSending = false
            completion()
            return
        }
        self.isSending = true
        DispatchQueue.main.async {
            switch messageAction.completion {
            case let callback as (() throws -> MessageHandle?):
                do {
                    self.messageHandle = try callback()
                    guard let _ = self.messageHandle else {
                        self.isSending = false
                        return
                    }
                } catch {
                    self.isSending = false
                    self.messageHandle = nil
                }
                
            case let callback as (() -> Void):
                self.isSending = true
                callback()
            default: return
            }
        }
    }
    
    @discardableResult
    func add(_ completion: @escaping () throws -> MessageHandle?) -> Self {
        let messageAction = MessageAction(message: "", completion: completion)
        self.messageQueue.append(messageAction)
        sendNext()
        return self
    }
    
    @discardableResult
    func addWithoutHandle(_ completion: @escaping () -> Void) -> Self {
        let messageAction = MessageAction(message: "", completion: completion)
        messageQueue.append(messageAction)
        sendNext()
        return self
    }
    
    func completion(_ completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    
    func done() {
        self.isSending = false
        if !messageQueue.isEmpty {
            messageQueue.removeFirst()
        }
        if messageQueue.isEmpty {
            completion()
        } else {
            self.sendNext()
        }
    }
    
    func remove() {
        messageQueue.removeAll()
    }
}

extension MeshMessageManager: MeshNetworkDelegate {
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: MeshAddress) {
        debouncer.call {
            var message = message
            if let type = jlResponseTypes.first(where: { $0.opCode == message.opCode }),
               let parameters = message.parameters,
               let msg = type.init(parameters: parameters) {
                message = msg
            }
            
            self.delegate?.meshNetworkManager(manager, didReceiveMessage: message, sentFrom: source, to: destination)
            print("received message: \(message)")
            
            self.done()
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didSendMessage message: MeshMessage,
                            from localElement: Element, to destination: MeshAddress) {
        delegate?.meshNetworkManager(manager, didSendMessage: message, from: localElement, to: destination)
        let isAckExpected = message is AcknowledgedMeshMessage || message is StaticVendorMessage
        if !isAckExpected {
            done()
        }
        if message is GLRunTimeMessage {
            done()
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            failedToSendMessage message: MeshMessage,
                            from localElement: Element, to destination: MeshAddress,
                            error: Error) {
        delegate?.meshNetworkManager(manager, failedToSendMessage: message, from: localElement, to: destination, error: error)
    }
}

public protocol MeshMessageDelegate {
    
    /// A callback called whenever a Mesh Message has been received
    /// from the mesh network.
    ///
    /// The `source` is given as an Address, instead of an Element, as
    /// the message may be sent by an unknown Node, or a Node which
    /// Elements are unknown.
    ///
    /// The `destination` address may be a Unicast Address of a local
    /// Element, a Group or Virtual Address, but also any other address
    /// if it was added to the Proxy Filter, e.g. a Unicast Address of
    /// an Element on a remote Node.
    ///
    /// - parameters:
    ///   - manager:     The manager which has received the message.
    ///   - message:     The received message.
    ///   - source:      The Unicast Address of the Element from which
    ///                  the message was sent.
    ///   - destination: The address to which the message was sent.
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: MeshAddress)
    
    /// A callback called when an unsegmented message was sent to the
    /// ``Transmitter``, or when all segments of a segmented message targeting
    /// a Unicast Address were acknowledged by the target Node.
    ///
    /// - parameters:
    ///   - manager:      The manager used to send the message.
    ///   - message:      The message that has been sent.
    ///   - localElement: The local Element used as a source of this message.
    ///   - destination:  The address to which the message was sent.
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didSendMessage message: MeshMessage,
                            from localElement: Element, to destination: MeshAddress)
    
    /// A callback called when a message failed to be sent to the target
    /// Node, or the response for an acknowledged message hasn't been received
    /// before the time run out.
    ///
    /// For unsegmented unacknowledged messages this callback will be invoked when
    /// the ``MeshNetworkManager/transmitter`` was set to `nil`, or has thrown an
    /// exception from ``Transmitter/send(_:ofType:)``.
    ///
    /// For segmented unacknowledged messages targeting a Unicast Address,
    /// besides that, it may also be called when sending timed out before all of
    /// the segments were acknowledged by the target Node, or when the target
    /// Node is busy and not able to proceed the message at the moment.
    ///
    /// For acknowledged messages the callback will be called when the response
    /// has not been received before the time set by ``NetworkParameters/acknowledgmentMessageTimeout``
    /// run out. The message might have been retransmitted multiple times
    /// and might have been received by the target Node. For acknowledged messages
    /// sent to a Group or Virtual Address this will be called when the response
    /// has not been received from any Node.
    ///
    /// Possible errors are:
    /// - Any error thrown by the ``Transmitter``.
    /// - ``BearerError/bearerClosed`` - when the ``MeshNetworkManager/transmitter``
    ///   object was not set.
    /// - ``LowerTransportError/busy`` - when the target Node is busy and can't
    ///   accept the message.
    /// - ``LowerTransportError/timeout`` - when the segmented message targeting
    ///   a Unicast Address was not acknowledged before the
    ///   ``NetworkParameters/sarUnicastRetransmissionsCount`` or
    ///   ``NetworkParameters/sarUnicastRetransmissionsWithoutProgressCount`` was reached
    ///   (for unacknowledged messages only).
    /// - ``AccessError/timeout`` - when the response for an acknowledged message
    ///   has not been received before the ``NetworkParameters/acknowledgmentMessageTimeout``
    ///   run out (for acknowledged messages only).
    ///
    /// - parameters:
    ///   - manager:      The manager used to send the message.
    ///   - message:      The message that has failed to be delivered.
    ///   - localElement: The local Element used as a source of this message.
    ///   - destination:  The address to which the message was sent.
    ///   - error:        The error that occurred.
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            failedToSendMessage message: MeshMessage,
                            from localElement: Element, to destination: MeshAddress,
                            error: Error)
    
}

public extension MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didSendMessage message: MeshMessage,
                            from localElement: Element, to destination: MeshAddress) {
        // Empty.
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            failedToSendMessage message: MeshMessage,
                            from localElement: Element, to destination: MeshAddress,
                            error: Error) {
        // Empty.
    }
    
}
