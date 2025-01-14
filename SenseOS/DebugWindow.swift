//
//  DebugWindow.swift
//  SenseOS
//
//  Created by Aleksandr Strizhnev on 14.01.2025.
//

import AppKit

extension CGRect {
    var flipped: CGRect {
        let screens = NSScreen.screens
        guard let screenWithWindow = (screens.first {
            NSPointInRect(self.origin, $0.frame)
        }) else {
            return self
        }
        
        return CGRect(
            x: self.minX,
            y: screenWithWindow.frame.height - self.origin.y - self.height,
            width: self.width,
            height: self.height
        )
    }
}

class DebugWindow: NSPanel {
    public convenience init(rect: CGRect) {
        self.init(
            contentRect: rect.flipped,
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        
        self.collectionBehavior = [.stationary, .ignoresCycle, .fullScreenAuxiliary, .canJoinAllSpaces, .canJoinAllApplications]
        self.isOpaque = false
        self.isMovable = false
        self.hasShadow = false
        self.level = .floating
        self.ignoresMouseEvents = true
        self.backgroundColor = .clear
        self.sharingType = .readOnly
    }
}
