//
//  UIButton+Extension.swift
//  nRF Mesh
//
//  Created by yan on 2024/6/29.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

extension UIButton {
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        clipsToBounds = true // maintain corner radius
        
        let colorImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            draw(.zero)
        }
        setBackgroundImage(colorImage, for: forState)
    }
}
