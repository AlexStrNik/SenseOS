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
    private var frontMostObserver: NSKeyValueObservation?
    private var connectedProcess: pid_t?
    
    @Published var rootElement: RootSenseElement = RootSenseElement()
    
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
        
        frontMostObserver = NSWorkspace.shared.observe(\.frontmostApplication, options: [.initial]) { _, _ in
            self.connectFrontmostWindow()
        }
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
        guard let processIdentifier, processIdentifier != connectedProcess else {
            return
        }
        connectedProcess = processIdentifier
        
        let appElement = AXUIElementCreateApplication(processIdentifier)
        
        rootElement.processIdentifier = processIdentifier
        rootElement.appElement = appElement
        rootElement.connectFocusedWindow()
        rootElement.handleFocus()
    }
    
    func requestAccesibility() {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true
        ]
        AXIsProcessTrustedWithOptions(options)
    }
}
