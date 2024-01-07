//
//  ExportView.swift
//  nRF Mesh
//
//  Created by yan on 2024/1/6.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct ExportView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let addSceneVc = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(identifier: "ExportViewController") as! UINavigationController
        
        return addSceneVc
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UINavigationController
    
    
}
