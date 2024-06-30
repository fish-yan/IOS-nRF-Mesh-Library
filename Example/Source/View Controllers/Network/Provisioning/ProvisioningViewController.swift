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
import NordicMesh

class ProvisioningViewController: UITableViewController {
    static let attentionTimer: UInt8 = 5
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unicastAddressLabel: UILabel!
    @IBOutlet weak var zoneLabel: UILabel!
    @IBOutlet weak var coordinateLabel: UILabel!
    
    // MARK: - Actions
    
    @IBOutlet weak var actionProvision: UIBarButtonItem!
    @IBAction func provisionTapped(_ sender: UIBarButtonItem) {
        guard bearer.isOpen else {
            openBearer()
            return
        }
        startProvisioning()
    }
    
    // MARK: - Properties
    
    weak var delegate: ProvisioningViewDelegate?
    var unprovisionedDevice: UnprovisionedDevice!
    var bearer: ProvisioningBearer!
    var previousNode: Node?
    
    private var publicKey: PublicKey?
    private var authenticationMethod: AuthenticationMethod?
    
    private var provisioningManager: ProvisioningManager!
    
    private let taskManager = MeshTaskManager()
    private var needConfigMore = false
    private var node: Node!
    private var zone: GLZone?
    
    private var alert: UIAlertController?
    
    // MARK: - View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let manager = MeshNetworkManager.instance
        nameLabel.text = unprovisionedDevice.name
        actionProvision.isEnabled = false
        // Obtain the Provisioning Manager instance for the Unprovisioned Device.
        do {
            provisioningManager = try manager.provision(unprovisionedDevice: unprovisionedDevice, over: bearer)
        } catch {
            switch error {
            case MeshNetworkError.nodeAlreadyExist:
                presentAlert(title: "Node already exist", message: "A node with the same UUID already exist in the network. Remove it before reprovisioning.") { _ in
                    self.dismiss(animated: true)
                }
            default:
                presentAlert(title: "Error", message: "A error occurred: \(error.localizedDescription)") { _ in
                    self.dismiss(animated: true)
                }
            }
            return
        }
        provisioningManager.delegate = self
        provisioningManager.logger = MeshNetworkManager.instance.logger
        bearer.delegate = self
        
        // Unicast Address initially will be assigned automatically.
        unicastAddressLabel.text = "Automatic"
        zoneLabel.text = "All"
        actionProvision.isEnabled = manager.meshNetwork!.localProvisioner != nil
        
        // We are now connected. Proceed by sending Provisioning Invite request.
        do {
            try self.provisioningManager.identify(andAttractFor: ProvisioningViewController.attentionTimer)
        } catch {
            self.abort()
            showError(error)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Make sure the bearer is closed when moving out from this screen.
        if isMovingFromParent {
            bearer.delegate = nil
            try? bearer.close()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "networkKey" {
            return provisioningManager.networkKey != nil
        }
        return true
    }
    
    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.isDeviceName {
            presentNameDialog()
        }
        if indexPath.isUnicastAddress {
            presentUnicastAddressDialog()
        }
        if indexPath.isCoordinate {
            presentCoordinateDialog()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectZone" {
            let vc = segue.destination as! PSelectZoneTableViewController
            vc.callback = { [weak self] zone in
                self?.zone = zone
                self?.zoneLabel.text = zone.name
            }
        }
    }
}

extension ProvisioningViewController: OobSelector {
    
}

private extension ProvisioningViewController {
    
    /// Presents a dialog to edit the Provisioner name.
    func presentNameDialog() {
        presentTextAlert(title: "Device name", message: nil,
                         text: unprovisionedDevice.name, placeHolder: "Name",
                         type: .nameRequired, cancelHandler: nil) { newName in
                            self.unprovisionedDevice.name = newName
                            self.nameLabel.text = newName
        }
    }
    
    /// Presents a dialog to edit or unbind the Provisioner Unicast Address.
    func presentUnicastAddressDialog() {
        let manager = self.provisioningManager!
        let action = UIAlertAction(title: "Automatic", style: .default) { [weak self] _ in
            guard let self = self else { return }
            manager.unicastAddress = manager.suggestedUnicastAddress
            self.unicastAddressLabel.text = manager.unicastAddress?.asString() ?? "Automatic"
            let deviceSupported = manager.isDeviceSupported == true
            let addressValid = manager.isUnicastAddressValid == true
            self.actionProvision.isEnabled = addressValid && deviceSupported
        }
        presentTextAlert(title: "Unicast address", message: "Hexadecimal value in Provisioner's range.",
                         text: manager.unicastAddress?.hex, placeHolder: "Address", type: .unicastAddressRequired,
                         option: action, cancelHandler: nil) { [weak self] text in
                            guard let self = self else { return }
                            manager.unicastAddress = Address(text, radix: 16)
                            self.unicastAddressLabel.text = manager.unicastAddress!.asString()
                            let deviceSupported = manager.isDeviceSupported == true
                            let addressValid = manager.isUnicastAddressValid == true
                            self.actionProvision.isEnabled = addressValid && deviceSupported
                            if !addressValid {
                                self.presentAlert(title: "Error", message: "Address is not available.")
                            }
        }
    }
    
    /// Presents a dialog to edit the Provisioner name.
    func presentCoordinateDialog() {
        presentTextAlert(
            title: "Coordinate",
            message: "Enter the position coordinates of the light, e.g: 0101",
            text: "",
            placeHolder: "coordinate",
            keyboardType: .numberPad,
            type: .coordinateRequired, cancelHandler: nil
        ) { coordinate in
            self.coordinateLabel.text = coordinate
        }
    }
    
    func presentStatusDialog(message: String, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let alert = self.alert {
                alert.message = message
                completion?()
            } else {
                self.alert = UIAlertController(title: "Status", message: message, preferredStyle: .alert)
                self.alert!.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
                    action.isEnabled = false
                    self.abort()
                })
                self.present(self.alert!, animated: flag, completion: completion)
            }
        }
    }
    
    func dismissStatusDialog(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let alert = self.alert {
                alert.dismiss(animated: true, completion: completion)
            } else {
                completion?()
            }
            self.alert = nil
        }
    }
    
    func abort() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.alert?.title   = "Aborting"
            self.alert?.message = "Cancelling connection..."
            do {
                try self.bearer.close()
            } catch {
                hidHUD()
                self.dismissStatusDialog() {
                    self.presentAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    func configureNode() {
        MeshNetworkManager.instance.delegate = self
        let localProvisioner = MeshNetworkManager.instance.meshNetwork?.localProvisioner
        guard localProvisioner?.hasConfigurationCapabilities ?? false else {
            // The Provisioner cannot sent or receive messages.
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.needConfigMore = true
            self.taskManager.append(.getCompositionData(page: 0))
            self.taskManager.append(.getDefaultTtl)
            self.executeNext()
        }
    }
    
    func configureMore() {
        let meshNetwork = MeshNetworkManager.instance.meshNetwork!
        guard let applicationKey = meshNetwork.applicationKey else {
            return
        }
        
        // add default applicationKey
        if !node.knows(applicationKey: applicationKey) {
            taskManager.append(.sendApplicationKey(applicationKey))
        }
        
        // bind applicationKey
        for model in node.usefulModels where !model.isBoundTo(applicationKey) {
            taskManager.append(.bind(applicationKey, to: model))
        }
        if node.companyIdentifier == 0x004c {
            needConfigMore = false
            return
        }
        
        // Subscriptions.
        for group in meshNetwork.defaultGroups {
            for model in node.usefulModels where !model.isSubscribed(to: group) {
                model.subscribe(to: group)
            }
        }
        // register scenes
        taskManager.append(.sceneRegisterGet)
        
        var coordinate = ""
        if let zone = zone?.number {
            coordinate += String(format: "%02d", zone)
        }
        coordinate += coordinateLabel.text ?? "0000"
        taskManager.append(.coordinate(coordinate))
        
        _ = MeshNetworkManager.instance.save()
        
        needConfigMore = false
    }
    
    func executeNext() {
        // Are we done?
        guard let task = taskManager.nextTask else {
            completed()
            return
        }
        if !isHUDShow {
            showHUD()
        }
        // Display the title of the current task.
        taskManager.update(status: .inProgress)
                
        var skipped: Bool!
        switch task {
        // Skip application keys if a network key was not sent.
        case .sendApplicationKey(let applicationKey):
            skipped = !node.knows(networkKey: applicationKey.boundNetworkKey)
        // Skip binding models to Application Keys not known to the Node.
        case .bind(let applicationKey, to: _):
            skipped = !node.knows(applicationKey: applicationKey)
        // Skip publication with keys that failed to be sent.
        case .setPublication(let publish, to: _):
            skipped = !node.knows(applicationKeyIndex: publish.index)
        default:
            skipped = false
        }
        
        guard !skipped else {
            taskManager.update(status: .skipped)
            executeNext()
            return
        }
        
        // Send the message.
        let manager = MeshNetworkManager.instance
        switch task.message {
        case let message as AcknowledgedConfigMessage:
            _ = try?  manager.send(message, to: node!.primaryUnicastAddress)
        case let message as GLMessage:
            guard let model = node.vendorModel else {
                return
            }
            _ = try? manager.send(message, to: model)
        case let message as SceneRegisterGet:
            guard let model = node.sceneModel else {
                return
            }
            _ = try? manager.send(message, to: model)
        default: break
        }
    }
    
    func completed() {
        if needConfigMore {
            configureMore()
            executeNext()
        } else {
            let saveZone = zone ?? GLMeshNetworkModel.instance.allZone
            saveZone.add(nodeAddress: node.primaryUnicastAddress)
            node.coordinate = coordinateLabel.text
            MeshNetworkManager.instance.saveAll()
            showSuccess() {
                self.delegate?.provisionerDidProvisionNewDevice(self.node, whichReplaced: self.previousNode)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

private extension ProvisioningViewController {    
    
    /// This method tries to open the bearer had it been closed when on this screen.
    func openBearer() {
        showHUD()
        do {
            try self.bearer.open()
        } catch {
            showError(error.localizedDescription)
        }
    }
    
    /// Starts provisioning process of the device.
    func startProvisioning() {
        guard let capabilities = provisioningManager.provisioningCapabilities else {
            return
        }
        
        guard let text = coordinateLabel.text,
                !text.isEmpty, text != "Unknown" else {
            showToast("coordinate cannot be unknown")
            return
        }
        
        // If the device's Public Key is available OOB, it should be read.
        let publicKeyNotAvailable = capabilities.publicKeyType.isEmpty
        guard publicKeyNotAvailable || publicKey != nil else {
            presentOobPublicKeyDialog(for: unprovisionedDevice) { [weak self] publicKey in
                guard let self = self else { return }
                self.publicKey = publicKey
                self.startProvisioning()
            }
            return
        }
        publicKey = publicKey ?? .noOobPublicKey
        
        // If any of OOB methods is supported, it should be chosen.
        let staticOobSupported = capabilities.oobType.contains(.staticOobInformationAvailable)
        let outputOobSupported = !capabilities.outputOobActions.isEmpty
        let inputOobSupported  = !capabilities.inputOobActions.isEmpty
        let anyOobSupported = staticOobSupported || outputOobSupported || inputOobSupported
        guard !anyOobSupported || authenticationMethod != nil else {
            presentOobOptionsDialog(for: provisioningManager, from: actionProvision) { [weak self] method in
                guard let self = self else { return }
                self.authenticationMethod = method
                self.startProvisioning()
            }
            return
        }
        // If none of OOB methods are supported, select the only option left.
        if authenticationMethod == nil {
            authenticationMethod = .noOob
        }
        
        if provisioningManager.networkKey == nil {
            let network = MeshNetworkManager.instance.meshNetwork!
            let networkKey = try! network.add(networkKey: Data.random128BitKey(), name: "Primary Network Key")
            provisioningManager.networkKey = networkKey
        }
        
        // Start provisioning.
        showHUD()
        do {
            try self.provisioningManager.provision(
                usingAlgorithm: capabilities.algorithms.strongest,
                publicKey:self.publicKey!,
                authenticationMethod: self.authenticationMethod!
            )
        } catch {
            self.abort()
            showError(error)
        }
    }
    
}

extension ProvisioningViewController: GattBearerDelegate {
    
    func bearerDidOpen(_ bearer: Bearer) {
        do {
            try self.provisioningManager!.identify(andAttractFor: ProvisioningViewController.attentionTimer)
        } catch {
            self.abort()
            showError(error.localizedDescription)
        }
    }
    
    func bearer(_ bearer: Bearer, didClose error: Error?) {
        guard case .complete = provisioningManager.state else {
            showError("Device disconnected.")
            return
        }
        let manager = MeshNetworkManager.instance
        if manager.save() {
            let connection = MeshNetworkManager.bearer!
            func done(reconnect: Bool) {
                if reconnect, let pbGattBearer = self.bearer as? PBGattBearer {
                    connection.disconnect()
                    // The bearer has closed. Attempt to send a message
                    // will fail, but the Proxy Filter will receive .bearerClosed
                    // error, upon which it will clear the filter list and notify
                    // the delegate.
                    manager.proxyFilter.proxyDidDisconnect()
                    manager.proxyFilter.clear()
                    
                    let gattBearer = GattBearer(targetWithIdentifier: pbGattBearer.identifier)
                    connection.use(proxy: gattBearer)
                }
                guard let network = manager.meshNetwork else {
                    return
                }
                if let node = network.node(for: self.unprovisionedDevice) {
                    self.node = node
                    self.configureNode()
                }
            }
            let reconnectAction = UIAlertAction(title: "Yes", style: .default) { _ in
                done(reconnect: true)
            }
            let continueAction = UIAlertAction(title: "No", style: .cancel) { _ in
                done(reconnect: false)
            }
            if connection.isConnected && bearer is PBGattBearer {
                self.presentAlert(title: "Success",
                                  message: "Provisioning complete.\n\nDo you want to connect to the new Node over GATT bearer?",
                                  options: [reconnectAction, continueAction])
            } else {
                done(reconnect: true)
            }
        } else {
            showError("Mesh configuration could not be saved.")
        }
    }
    
}

extension ProvisioningViewController: ProvisioningDelegate {
    
    func provisioningState(of unprovisionedDevice: UnprovisionedDevice, didChangeTo state: ProvisioningState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch state {
            case .capabilitiesReceived:
                // If the Unicast Address was set to automatic (nil), it should be
                // set to the correct value by now, as we know the number of elements.
                let addressValid = self.provisioningManager.isUnicastAddressValid == true
                if !addressValid {
                   self.provisioningManager.unicastAddress = nil
                }
                self.unicastAddressLabel.text = self.provisioningManager.unicastAddress?.asString() ?? "No address available"
                self.actionProvision.isEnabled = addressValid
                                
                let deviceSupported = self.provisioningManager.isDeviceSupported == true
                if !deviceSupported {
                    showError("Selected device is not supported.")
                    self.actionProvision.isEnabled = false
                } else if !addressValid {
                    showError("No available Unicast Address in Provisioner's range.")
                }
                
            case .complete:
                do {
                    try self.bearer.close()
                } catch {
                    showError(error)
                }
                
            case let .failed(error):
                showError(error)
                self.abort()
                
            default:
                break
            }
        }
    }
    
    func authenticationActionRequired(_ action: AuthAction) {
        switch action {
            
        case let .provideStaticKey(callback: callback):
            guard let capabilities = provisioningManager.provisioningCapabilities else {
                return
            }
            let algorithm = capabilities.algorithms.strongest
            
            self.dismissStatusDialog {
                let requiredSize = algorithm == .BTM_ECDH_P256_HMAC_SHA256_AES_CCM ? 32 : 16
                let type: Selector = algorithm == .BTM_ECDH_P256_HMAC_SHA256_AES_CCM ? .key32Required : .key16Required
                
                let message = "Enter \(requiredSize)-character hexadecimal string."
                self.presentTextAlert(title: "Static OOB Key", message: message,
                                      type: type, cancelHandler: nil) { hex in
                    callback(Data(hex: hex))
                }
            }
            
        case let .provideNumeric(maximumNumberOfDigits: _, outputAction: action, callback: callback):
            self.dismissStatusDialog {
                var message: String
                switch action {
                case .blink:
                    message = "Enter number of blinks."
                case .beep:
                    message = "Enter number of beeps."
                case .vibrate:
                    message = "Enter number of vibrations."
                case .outputNumeric:
                    message = "Enter the number displayed on the device."
                default:
                    message = "Action \(action) is not supported."
                }
                self.presentTextAlert(title: "Authentication", message: message,
                                      type: .unsignedNumberRequired, cancelHandler: nil) { text in
                    callback(UInt(text)!)
                }
            }
            
        case let .provideAlphanumeric(maximumNumberOfCharacters: _, callback: callback):
            self.dismissStatusDialog {
                let message = "Enter the text displayed on the device."
                self.presentTextAlert(title: "Authentication", message: message,
                                      type: .nameRequired, cancelHandler: nil) { text in
                    callback(text)
                }
            }
            
        case let .displayAlphanumeric(text):
            self.presentStatusDialog(message: "Enter the following text on your device:\n\n\(text)")
            
        case let .displayNumber(value, inputAction: action):
            self.presentStatusDialog(message: "Perform \(action) \(value) times on your device.")
        }
    }
    
    func inputComplete() {
        self.presentStatusDialog(message: "Provisioning...")
    }
    
}


extension ProvisioningViewController: MeshNetworkDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: MeshAddress) {
        // Is the message targeting the current Node?
        guard node.primaryUnicastAddress == source else {
            return
        }
        
        // Handle the message based on its type.
        if let task = taskManager.task {
            var valid = true
            if let taskMessage = task.message as? AcknowledgedMeshMessage {
                valid = message.opCode == taskMessage.responseOpCode
            }
            if valid {
                if let status = message as? ConfigStatusMessage {
                    taskManager.update(status: .resultOf(status))
                } else {
                    taskManager.update(status: .success)
                }
                executeNext()
            }
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            failedToSendMessage message: MeshMessage,
                            from localElement: Element, to destination: MeshAddress,
                            error: Error) {
        taskManager.update(status: .failed(error))
        completed()
        // Ignore messages sent using model publication.
        guard message is ConfigMessage else {
            return
        }
        showError(error)
    }
    
}


extension ProvisioningViewController: SelectionDelegate {
    
    func networkKeySelected(_ networkKey: NetworkKey?) {
        self.provisioningManager.networkKey = networkKey
        self.zoneLabel.text = networkKey?.name ?? "New Network Key"
    }
    
}

private extension IndexPath {
    
    /// Returns whether the IndexPath points the Device Name.
    var isDeviceName: Bool {
        return row == 0
    }
    
    /// Returns whether the IndexPath point to the Unicast Address settings.
    var isUnicastAddress: Bool {
        return row == 1
    }
    
    var isZone: Bool {
        return row == 2
    }
    
    var isCoordinate: Bool {
        return row == 3
    }
    
}

private extension String {
    
    // Replaces ", " to new line.
    //
    // The `debugDescription` in the library returns values separated
    // with commas.
    var toLines: String {
        return replacingOccurrences(of: ", ", with: "\n")
    }
    
}
