//
//  PNodeDetailTableViewController.swift
//  nRF Mesh
//
//  Created by yan on 2024/6/30.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

class PNodeDetailTableViewController: UITableViewController {
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var addressLab: UILabel!
    @IBOutlet weak var zoneLab: UILabel!
    @IBOutlet weak var bk06zoneLab: UILabel!
    @IBOutlet weak var updateSwitch: UISwitch!
    
    var node: Node!
    private var zone: GLZone!
    private let messageManager = MeshMessageManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = node.name ?? "Unknown"
        nameLab.text = node.name ?? "Unknown"
        addressLab.text = node.primaryUnicastAddress.asString()
        zoneLab.text = GLMeshNetworkModel.instance.zone(node: node).name
        bk06zoneLab.text = GLMeshNetworkModel.instance.zone(node: node).name
        updateSwitch.isOn = node.isUpdating
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageManager.delegate = self
        zoneLab.text = GLMeshNetworkModel.instance.zone(node: node).name
        bk06zoneLab.text = GLMeshNetworkModel.instance.zone(node: node).name
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isBk06 = node.productType == .sceneTouchPad
        if indexPath == .zoneNode {
            return isBk06 ? 0 : UITableView.automaticDimension
        }
        if indexPath == .bk06ZoneNode {
            return isBk06 ? UITableView.automaticDimension : 0
        }
        if indexPath == .k9Node {
            return isBk06 ? 0 : UITableView.automaticDimension
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case .nameNode:
            presentNameDialog()
        case .resetNode:
            presentResetConfirmation()
        case .removeNode:
            presentRemoveNodeConfirmation()
        default: break
        }
    }
    
    /// Presents a dialog to edit the Provisioner name.
    func presentNameDialog() {
        presentTextAlert(title: "Device name", message: nil,
                         text: node.name, placeHolder: "Name",
                         type: .nameRequired, cancelHandler: nil) { newName in
            self.node.name = newName
            self.nameLab.text = newName
            self.title = newName
            MeshNetworkManager.instance.saveAll()
        }
    }
    
    /// Presents a dialog with resetting confirmation.
    func presentResetConfirmation() {
        let alert = UIAlertController(title: Localized("Reset Node"),
                                      message: Localized("Resetting the node will change its state back to unprovisioned state and remove it from the local database."),
                                      preferredStyle: .actionSheet)
        let resetAction = UIAlertAction(title: Localized("Reset"), style: .destructive) { [weak self] _ in self?.resetNode() }
        let cancelAction = UIAlertAction(title: Localized("Cancel"), style: .cancel)
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    /// Presents a dialog with resetting confirmation.
    func presentRemoveNodeConfirmation() {
        let alert = UIAlertController(title: "Remove Node",
                                      message: "The node will only be removed from the local database. It will still be able to send and receive messages from the network. Remove the node only if the device is no longer available.",
                                      preferredStyle: .actionSheet)
        let resetAction = UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in self?.removeNode() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(resetAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @IBAction func updateAction(_ sender: UISwitch) {
        let message = GLUpdateMessage(value: sender.isOn)
        guard let model = node.vendorModel else { return }
        _ = try? MeshNetworkManager.instance.send(message, to: model)
        node.isUpdating = sender.isOn
        MeshNetworkManager.instance.saveAll()
    }
    
    /// Sends a message to the node that will reset its state to unprovisioned.
    func resetNode() {
        showHUD()
        let message = ConfigNodeReset()
        _ = try? MeshNetworkManager.instance.send(message, to: node.primaryUnicastAddress)
    }
    
    /// Removes the Node from the local database and pops the Navigation Controller.
    func removeNode() {
        node.coordinate = nil
        MeshNetworkManager.instance.meshNetwork!.remove(node: node)
        let zone = GLMeshNetworkModel.instance.zone(node: node)
        zone.remove(nodeAddress: node.primaryUnicastAddress)
        MeshNetworkManager.instance.saveAll()
        navigationController!.popViewController(animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "position" {
            let vc = segue.destination as! PChangePositionTableViewController
            vc.node = node
        } else if segue.identifier == "more" {
            let vc = segue.destination as! NodeViewController
            vc.node = node
        } else if segue.identifier == "bk06Zone" {
            let vc = segue.destination as! PSelectZoneTableViewController
            vc.callback = { [weak self] zone in
                guard let self else { return }
                self.zone = zone
                self.bk06zoneLab.text = zone.name
                let message = GLBK06ZoneMessage(zone: zone.number)
                guard let model = self.node.vendorModel else {
                    return
                }
                showHUD()
                _ = try? MeshNetworkManager.instance.send(message, to: model)
            }
        } else if segue.identifier == "k9List" {
            let vc = segue.destination as! PK9ListViewController
            vc.node = node
        }
    }

}

extension PNodeDetailTableViewController: MeshMessageDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: MeshAddress) {
        if message is ConfigNodeResetStatus {
            node.coordinate = nil
            let zone = GLMeshNetworkModel.instance.zone(node: node)
            zone.remove(nodeAddress: node.primaryUnicastAddress)
            GLMeshNetworkModel.instance.k9s
                .filter {$0.nodeAddress == node.primaryUnicastAddress}
                .forEach { GLMeshNetworkModel.instance.remove(k9: $0) }
            MeshNetworkManager.instance.saveAll()
            hidHUD()
            navigationController?.popToRootViewController(animated: true)
        } else if message is GLControlStatus {
            let saveZone = self.zone ?? GLMeshNetworkModel.instance.allZone
            saveZone.add(nodeAddress: self.node.primaryUnicastAddress)
            MeshNetworkManager.instance.saveAll()
            showSuccess()
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            failedToSendMessage message: MeshMessage,
                            from localElement: Element, to destination: MeshAddress,
                            error: Error) {
        showError(error)
    }
    
}

extension IndexPath {
    static let nameNode = IndexPath(row: 0, section: 0)
    static let zoneNode = IndexPath(row: 2, section: 0)
    static let bk06ZoneNode = IndexPath(row: 3, section: 0)
    static let k9Node = IndexPath(row: 4, section: 0)
    static let resetNode = IndexPath(row: 1, section: 2)
    static let removeNode = IndexPath(row: 2, section: 2)
}
