//
//  ScenesHostViewController.swift
//  nRF Mesh
//
//  Created by yan on 2023/10/9.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import SwiftUI

class ScenesHostViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBSegueAction func showLightsView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: ScenesListView())
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
