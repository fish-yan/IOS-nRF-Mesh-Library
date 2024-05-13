//
//  ItemView.swift
//  nRF Mesh
//
//  Created by yan on 2023/9/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct ItemView: View {
    var resource: ImageResource?
    var systemName: String?
    var title: String
    var detail: String
    
    init(resource: ImageResource, title: String, detail: String) {
        self.resource = resource
        self.title = title
        self.detail = detail
    }
    
    init(systemName: String, title: String, detail: String) {
        self.systemName = systemName
        self.title = title
        self.detail = detail
    }
    
    var body: some View {
        HStack {
            resource != nil ? 
            Image(resource!)
                .frame(width: 48, height: 48)
            :
            Image(systemName: systemName!)
                .frame(width: 48, height: 48)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
        }
    }
}
