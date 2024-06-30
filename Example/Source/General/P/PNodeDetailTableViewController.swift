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
    
    
    var node: Node!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = node.name ?? "Unknown"
        nameLab.text = node.name ?? "Unknown"
        addressLab.text = node.primaryUnicastAddress.asString()
        zoneLab.text = GLMeshNetworkModel.instance.zone(node: node).name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MeshNetworkManager.instance.delegate = self
        zoneLab.text = GLMeshNetworkModel.instance.zone(node: node).name
    }

    // MARK: - Table view data source
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
            MeshNetworkManager.instance.saveAll()
        }
    }
    
    /// Presents a dialog with resetting confirmation.
    func presentResetConfirmation() {
        let alert = UIAlertController(title: "Reset Node",
                                      message: "Resetting the node will change its state back to unprovisioned state and remove it from the local database.",
                                      preferredStyle: .actionSheet)
        let resetAction = UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in self?.resetNode() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
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
        }
    }

}

extension PNodeDetailTableViewController: MeshNetworkDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: MeshAddress) {
        node.coordinate = nil
        let zone = GLMeshNetworkModel.instance.zone(node: node)
        zone.remove(nodeAddress: node.primaryUnicastAddress)
        MeshNetworkManager.instance.saveAll()
        hidHUD()
        navigationController?.popToRootViewController(animated: true)
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
    static let resetNode = IndexPath(row: 0, section: 2)
    static let removeNode = IndexPath(row: 1, section: 2)
}
