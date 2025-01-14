//
//  SenseOSApp.swift
//  SenseOS
//
//  Created by Aleksandr Strizhnev on 14.01.2025.
//

import SwiftUI
import Combine
import GameController

enum MoveFocusDirection {
    case up
    case down
    case left
    case right
}

class SenseOSApp: NSObject, NSApplicationDelegate {
    private var debugWindow: NSWindow?
    
    @Published var rootElement: RootSenseElement = RootSenseElement(
        processIdentifier: -1,
        child: nil
    )
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        requestAccesibility()
        
        connectFrontmostWindow()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(connectController), name: NSNotification.Name.GCControllerDidConnect, object: nil
        )
        GCController.shouldMonitorBackgroundEvents = true
        
        debugWindow = DebugWindow(
            rect: NSScreen.screens.first!.frame
        )
        debugWindow?.contentView = NSHostingView(
            rootView: DebugView(
                element: rootElement
            )
        )
        debugWindow?.orderFrontRegardless()
    }
    
    @objc func connectController() {
        let controller = GCController.controllers().first
        
        guard let controller else {
            return
        }
        
        guard let gamepad = controller.extendedGamepad as? GCDualSenseGamepad else {
            return
        }
        
        gamepad.dpad.left.pressedChangedHandler = { _, _, isPressed in
            if isPressed {
                _ = self.rootElement.handleFocusMove(direction: .left)
            }
        }
        gamepad.dpad.right.pressedChangedHandler = { _, _, isPressed in
            if isPressed {
                _ = self.rootElement.handleFocusMove(direction: .right)
            }
        }
        gamepad.dpad.up.pressedChangedHandler = { _, _, isPressed in
            if isPressed {
                _ = self.rootElement.handleFocusMove(direction: .up)
            }
        }
        gamepad.dpad.down.pressedChangedHandler = { _, _, isPressed in
            if isPressed {
                _ = self.rootElement.handleFocusMove(direction: .down)
            }
        }
        gamepad.buttonA.pressedChangedHandler = { _, _, isPressed in
            if isPressed {
                self.rootElement.handlePress()
            }
        }
        gamepad.rightThumbstick.valueChangedHandler = { _, x, y in
            self.rootElement.handleScroll(x: CGFloat(x), y: CGFloat(y))
        }
        gamepad.leftShoulder.pressedChangedHandler = { _, _, isPressed in
            if isPressed {
                _ = self.rootElement.handleFocusPrev()
            }
        }
        gamepad.rightShoulder.pressedChangedHandler = { _, _, isPressed in
            if isPressed {
                _ = self.rootElement.handleFocusNext()
            }
        }
    }
    
    func connectFrontmostWindow() {
        let processIdentifier = NSWorkspace.shared.frontmostApplication?.processIdentifier
        guard let processIdentifier else {
            return
        }
        
        let appElement = AXUIElementCreateApplication(processIdentifier)
        let windowElement = appElement.attribute(kAXFocusedWindowAttribute) as! AXUIElement
        
        let contentElement = windowElement.children?.first
        guard let contentElement else {
            return
        }
        
        rootElement = RootSenseElement(
            processIdentifier: processIdentifier,
            child: nil
        )
        rootElement.focusedWindow = visitChild(contentElement)
        rootElement.handleFocus()
    }
    
    func requestAccesibility() {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true
        ]
        AXIsProcessTrustedWithOptions(options)
    }
}
