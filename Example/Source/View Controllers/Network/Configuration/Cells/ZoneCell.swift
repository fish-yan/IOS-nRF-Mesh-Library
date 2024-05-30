//
//  ZoneCell.swift
//  nRF Mesh
//
//  Created by yan on 2024/5/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

class ZoneCell: UITableViewCell {
    var node: Node! {
        didSet {
            if let zone = GLMeshNetworkModel.instance.zone.first(where: {$0.nodeAddresses.contains(node.primaryUnicastAddress) && $0.zone != 0}) {
                numberTF.text = String(zone.zone, radix: 16)
            }
            
        }
    }
    @IBOutlet weak var numberTF: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func saveAction(_ sender: UIButton) {
        var zones = GLMeshNetworkModel.instance.zone
        if let text = numberTF.text,
           let num = UInt8(text, radix: 16) {
            if let zone = zones.first(where: {$0.zone == num}) {
                zone.add(nodeAddress: node.primaryUnicastAddress)
            } else {
                let zone = GLZone(name: "Zone \(num)", zone: num)
                zone.add(nodeAddress: node.primaryUnicastAddress)
                zones.append(zone)
            }
        }
        GLMeshNetworkModel.instance.zone = zones
        MeshNetworkManager.instance.saveAll()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
