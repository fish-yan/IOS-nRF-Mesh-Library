//
//  GLCommon.swift
//  nRF Mesh
//
//  Created by yan on 2024/6/15.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import ProgressHUD

private let hudDebouncer = Debouncer(label: "hud", interval: 500)

private(set) var isHUDShow = false

private var workItem: DispatchWorkItem?

public func toast(_ text: String) {
    ProgressHUD.animate(text, .none)
    workItem?.cancel()
    workItem = nil
    isHUDShow = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        ProgressHUD.dismiss()
        isHUDShow = false
    }
}

public func showHUD(_ text: String? = nil) {
    ProgressHUD.animate(text, .semiRingRotation, interaction: false)
    isHUDShow = true
    workItem = DispatchWorkItem {
        if isHUDShow {
            showError("Time out")
        }
    }
    guard let workItem else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: workItem)
}

public func hidHUD() {
    ProgressHUD.dismiss()
    workItem?.cancel()
    workItem = nil
    isHUDShow = false
}

public func showError(_ text: String? = nil) {
    hudDebouncer.call {
        ProgressHUD.failed(text, interaction: false, delay: 2)
        workItem?.cancel()
        workItem = nil
        isHUDShow = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            workItem?.cancel()
        }
    }
}

public func showError(_ error: Error) {
    showError(error.localizedDescription)
}

public func showSuccess(_ text: String? = nil, completion: @escaping  () -> Void = {}) {
    ProgressHUD.succeed(text, interaction: false, delay: 2)
    workItem?.cancel()
    workItem = nil
    isHUDShow = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        isHUDShow = false
        completion()
    }
}

func Localized(_ key: String) -> String {
    if let path = Bundle.main.path(forResource: AppManager.manager.language.rawValue, ofType: "lproj"),
       let str = Bundle(path: path)?.localizedString(forKey: key, value: nil, table: "Localizable") {
        return str
    } else if let path = Bundle.main.path(forResource: "en", ofType: "lproj"),
              let str = Bundle(path: path)?.localizedString(forKey: key, value: nil, table: "Localizable") {
        return str
    } else {
        return key
    }
}
