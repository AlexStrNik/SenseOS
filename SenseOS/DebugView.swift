//
//  DebugView.swift
//  SenseOS
//
//  Created by Aleksandr Strizhnev on 14.01.2025.
//

import SwiftUI
import Accessibility
import Combine

struct DebugView: View {
    @ObservedObject var element: RootSenseElement
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            let elements = element.debugElements ?? []
            
            ForEach(Array(elements.enumerated()), id: \.offset) { _, element in
                let rect = element.frame
                
                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                    .stroke(element.focused ? .green : .red.opacity(0.1), lineWidth: 2)
                    .offset(x: rect.minX, y: rect.minY)
                    .frame(width: rect.width, height: rect.height)
                    .zIndex(element.focused ? 9999 : -1)
            }
            Color.clear
        }
        .compositingGroup()
    }
}
