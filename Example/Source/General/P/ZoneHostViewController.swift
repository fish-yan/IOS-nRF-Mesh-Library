//
//  ZoneHostViewController.swift
//  nRF Mesh
//
//  Created by yan on 2024/6/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SwiftUI

class ZoneHostViewController: UIHostingController<PZoneListView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: PZoneListView())
    }
}
