//
//  MeshSegmentView.swift
//  nRF Mesh
//
//  Created by yan on 2024/4/2.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import SwiftUI

struct MeshSegmentView: View {
    let segments: [String]
    @Binding var selectedSegment: Int
    @State private var segmentWidths: [CGFloat] = []
    
    var body: some View {
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .lastTextBaseline, spacing: 20) {
                    ForEach(segments.indices, id: \.self) { index in
                        Button(segments[index]) {
                            selectedSegment = index
                        }
                        .font(selectedSegment == index ? .pageTitleSelected : .pageTitleNormal)
                        .foregroundStyle(selectedSegment == index ? Color.accent : Color.secondary)
                        
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: SegmentWidthPreferenceKey.self,
                                    value: [SegmentWidthPreferenceData(
                                        index: index,
                                        width: geometry.size.width
                                    )]
                                )
                            }
                        )
                    }
                    Spacer()
                }
                .onPreferenceChange(SegmentWidthPreferenceKey.self) { preferences in
                    segmentWidths = preferences.map { $0.width }
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.accent)
                    .frame(width: 22, height: 2)
                    .offset(x: segmentOffset(for: selectedSegment))
                    .animation(.spring, value: selectedSegment)
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
        .scrollIndicators(.hidden)
    }
    
    private func segmentOffset(for index: Int) -> CGFloat {
        var offset: CGFloat = 0
        for i in 0..<index {
            offset += (segmentWidths[i] + 20)
        }
        return offset
    }
}

struct SegmentWidthPreferenceData: Equatable {
    let index: Int
    let width: CGFloat
}

struct SegmentWidthPreferenceKey: PreferenceKey {
    typealias Value = [SegmentWidthPreferenceData]
    
    static var defaultValue: [SegmentWidthPreferenceData] = []
    
    static func reduce(value: inout [SegmentWidthPreferenceData], nextValue: () -> [SegmentWidthPreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}
