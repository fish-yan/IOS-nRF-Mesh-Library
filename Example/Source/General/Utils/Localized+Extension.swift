//
//  UILabel+Localized.swift
//  nRF Mesh
//
//  Created by yan on 2024/7/13.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

extension UILabel {
    @IBInspectable var localizedText: String {
        get {
            text ?? ""
        }
        set {
            text = Localized(newValue)
        }
    }
}

extension UINavigationItem {
    @IBInspectable var localizedText: String {
        get {
            title ?? ""
        }
        set {
            title = Localized(newValue)
        }
    }
}

extension UIBarButtonItem {
    @IBInspectable var localizedText: String {
        get {
            title ?? ""
        }
        set {
            title = Localized(newValue)
        }
    }
}

extension UIButton {
    @IBInspectable var localizedText: String {
        get {
            title(for: .normal) ?? ""
        }
        set {
            setTitle(Localized(newValue), for: .normal)
        }
    }
}

extension UITabBarItem {
    @IBInspectable var localizedText: String {
        get {
            title ?? ""
        }
        set {
            title = Localized(newValue)
        }
    }
}
