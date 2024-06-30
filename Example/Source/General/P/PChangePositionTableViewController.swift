//
//  PChangePositionTableViewController.swift
//  nRF Mesh
//
//  Created by yan on 2024/6/30.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

class PChangePositionTableViewController: UITableViewController {
    @IBOutlet weak var zoneLab: UILabel!
    @IBOutlet weak var coordinateLab: UILabel!
    var node: Node!
    private var zone: GLZone!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zone = GLMeshNetworkModel.instance.zone(node: node)
        zoneLab.text = zone.name
        coordinateLab.text = node.coordinate ?? "Unknown"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MeshNetworkManager.instance.delegate = self
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        guard let text = coordinateLab.text,
                !text.isEmpty, text != "Unknown" else {
            showToast("coordinate cannot be unknown")
            return
        }
        var coordinate = ""
        if let zone = zone?.number {
            coordinate += String(format: "%02d", zone)
        }
        coordinate += coordinateLab.text ?? "0000"
        let message = GLCoordinateMessage(coordinate: coordinate)
        guard let model = node.vendorModel else {
            return
        }
        showHUD()
        _ = try? MeshNetworkManager.instance.send(message, to: model)
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
            self.coordinateLab.text = coordinate
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.isCoordinate {
            presentCoordinateDialog()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectZone" {
            let vc = segue.destination as! PSelectZoneTableViewController
            vc.callback = { [weak self] zone in
                self?.zone = zone
                self?.zoneLab.text = zone.name
            }
        }
    }

}

extension PChangePositionTableViewController: MeshNetworkDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: MeshAddress) {
        let saveZone = zone ?? GLMeshNetworkModel.instance.allZone
        saveZone.add(nodeAddress: node.primaryUnicastAddress)
        node.coordinate = coordinateLab.text
        MeshNetworkManager.instance.saveAll()
        showSuccess() {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            failedToSendMessage message: MeshMessage,
                            from localElement: Element, to destination: MeshAddress,
                            error: Error) {
        showError(error)
    }
    
}

private extension IndexPath {
    
    var isCoordinate: Bool {
        return row == 1
    }
    
}
