//
//  UINavigationController+SwipBack.swift
//  nRF Mesh
//
//  Created by yan on 2024/4/1.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
