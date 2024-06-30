//
//  PZoneListTableViewController.swift
//  nRF Mesh
//
//  Created by yan on 2024/6/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class PZoneListTableViewController: UITableViewController {
    private var zones: [GLZone] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        zones = GLMeshNetworkModel.instance.zones
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zones.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let zone = zones[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath) as! DeviceCell
        cell.name.text = zone.name
        cell.uuid.text = "Address: 0x" + String(zone.number, radix: 16)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let zone = zones[indexPath.row]
        self.performSegue(withIdentifier: "zoneDetail", sender: zone)
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "zoneDetail" {
            let vc = segue.destination as! PZoneDetailViewController
            vc.zone = sender as? GLZone
        }
    }

}
