//
//  PSelectZoneTableViewController.swift
//  nRF Mesh
//
//  Created by yan on 2024/6/30.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class PSelectZoneTableViewController: UITableViewController {
    var callback: ((GLZone) -> Void)?
    
    private var zones: [GLZone] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        zones = GLMeshNetworkModel.instance.zones
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return zones.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell()
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Create new zone"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Subtitle", for: indexPath)
            let zone = zones[indexPath.row]
            cell.accessoryType = .none
            cell.textLabel?.text = zone.name
            cell.detailTextLabel?.text = "0x" + String(zone.number, radix: 16)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "newZone", sender: nil)
        } else {
            let zone = zones[indexPath.row]
            callback?(zone)
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newZone" {
            let vc = segue.destination as! PZoneDetailViewController
            vc.callback = callback
        }
    }
}
