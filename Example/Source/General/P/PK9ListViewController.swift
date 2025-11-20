//
//  PK9ListViewController.swift
//  nRF Mesh
//
//  Created by yan on 19/1/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import NordicMesh

class PK9ListViewController: UITableViewController {
    
    var k9s: [GLK9] = []
    var node: Node!

    @IBOutlet weak var addK9: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        k9s = GLMeshNetworkModel.instance.k9s.filter {
            $0.nodeAddress == node.primaryUnicastAddress
        }
        addK9.isEnabled = k9s.count < 5
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func createK9Action(_ sender: Any) {
        performSegue(withIdentifier: "k9Detail", sender: nil)
    }
    
    @IBAction func trashAction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Warning", message: "Do you confirm delete?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Cancel", style: .cancel)
        let action2 = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.unbindK9s()
        }
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true)
    }
    
    func unbindK9s() {
        guard let model = node.vendorModel else { return }
        let message = GLK9ConnectMessage(number: 0)
        _ = try? MeshNetworkManager.instance.send(message, to: model)
        showHUD()
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            k9s.forEach {
                GLMeshNetworkModel.instance.remove(k9: $0)
            }
            k9s.removeAll()
            MeshNetworkManager.instance.saveAll()
            tableView.reloadData()
            showSuccess()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        k9s.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "k9", for: indexPath)
        let k9 = k9s[indexPath.row]
        cell.textLabel?.text = "\(k9.name)"
        cell.detailTextLabel?.text = "\(k9.number)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let k9 = k9s[indexPath.row]
        performSegue(withIdentifier: "k9Detail", sender: k9)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "k9Detail" {
            let vc = segue.destination as? PK9DetailViewController
            vc?.k9 = sender as? GLK9
            vc?.node = node
        }
    }
}
