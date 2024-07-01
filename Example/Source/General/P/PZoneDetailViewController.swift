//
//  PZoneDetailViewController.swift
//  nRF Mesh
//
//  Created by yan on 2024/6/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

class PZoneDetailViewController: UIViewController {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    var zone: GLZone?
    var callback: ((GLZone) -> Void)?
    
    private var nextZoneNumber: UInt8 = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        saveBtn.setBackgroundColor(color: .accent, forState: .normal)
        saveBtn.setBackgroundColor(color: UIColor(white: 0.7, alpha: 1), forState: .disabled)
        if let zone {
            title = zone.name
            nameTF.text = zone.name
            numberTF.text = "0x" + String(zone.number, radix: 16)
            cancelBtn.setTitle("Delete", for: .normal)
            cancelBtn.setTitleColor(UIColor.red, for: .normal)
            cancelBtn.isHidden = zone.number == 0
        } else {
            saveBtn.isEnabled = false
            title = "New zone"
            nextZoneNumber = GLMeshNetworkModel.instance.nextZone()
            numberTF.text = "0x" + String(nextZoneNumber, radix: 16)
        }
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        view.endEditing(true)
        if let zone {
            zone.name = nameTF.text ?? ""
        } else {
            let zone = GLZone(name: nameTF.text ?? "", number: nextZoneNumber)
            GLMeshNetworkModel.instance.add(zone)
            callback?(zone)
        }
        MeshNetworkManager.instance.saveAll()
        if callback != nil,
           let vc = navigationController?.viewControllers.first(where: {$0 is ProvisioningViewController}) {
            navigationController?.popToViewController(vc, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        view.endEditing(true)
        if let zone {
            let alert = UIAlertController(title: "Warning", message: "Do you confirm delete this zone?", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Cancel", style: .cancel)
            let action2 = UIAlertAction(title: "Delete", style: .destructive) { _ in
                GLMeshNetworkModel.instance.remove(zone)
                MeshNetworkManager.instance.saveAll()
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(action1)
            alert.addAction(action2)
            present(alert, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        if let text = sender.text,
           !text.isEmpty {
            saveBtn.isEnabled = true
        } else {
            saveBtn.isEnabled = false
        }
    }
}
