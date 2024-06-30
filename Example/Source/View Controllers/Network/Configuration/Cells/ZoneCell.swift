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
            if let zone = GLMeshNetworkModel.instance.zones.first(where: {$0.nodeAddresses.contains(node.primaryUnicastAddress) && $0.number != 0}) {
                numberTF.text = String(zone.number, radix: 16)
            }
            
        }
    }
    @IBOutlet weak var numberTF: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func saveAction(_ sender: UIButton) {
        let zones = GLMeshNetworkModel.instance.zones
        if let text = numberTF.text,
           let num = UInt8(text, radix: 16) {
            if let zone = zones.first(where: {$0.number == num}) {
                zone.add(nodeAddress: node.primaryUnicastAddress)
            } else {
                let zone = GLZone(name: "Zone \(num)", number: num)
                zone.add(nodeAddress: node.primaryUnicastAddress)
                GLMeshNetworkModel.instance.add(zone)
            }
        }
        MeshNetworkManager.instance.saveAll()
        toast("save success")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
