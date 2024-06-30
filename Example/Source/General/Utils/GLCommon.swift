//
//  GLCommon.swift
//  nRF Mesh
//
//  Created by yan on 2024/6/15.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import ProgressHUD

private(set) var isHUDShow = false

public func toast(_ text: String) {
    ProgressHUD.animate(text, .none)
    isHUDShow = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        ProgressHUD.dismiss()
        isHUDShow = false
    }
}

public func showHUD(_ text: String? = nil) {
    ProgressHUD.animate(text, .semiRingRotation, interaction: false)
    isHUDShow = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
        if isHUDShow {
            showError("Time out")
        }
    }
}

public func hidHUD() {
    ProgressHUD.dismiss()
    isHUDShow = false
}

public func showError(_ text: String? = nil) {
    ProgressHUD.failed(text, interaction: false, delay: 2)
    isHUDShow = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        isHUDShow = false
    }
}

public func showError(_ error: Error) {
    showError(error.localizedDescription)
}

public func showSuccess(_ text: String? = nil, completion: @escaping  () -> Void = {}) {
    ProgressHUD.succeed(text, interaction: false, delay: 2)
    isHUDShow = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        isHUDShow = false
        completion()
    }
}
