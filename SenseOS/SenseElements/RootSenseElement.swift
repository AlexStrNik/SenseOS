//
//  RootSenseElement.swift
//  SenseOS
//
//  Created by Aleksandr Strizhnev on 14.01.2025.
//

import ApplicationServices

func rootObserverCallback(
    _ observer: AXObserver,
    _ element: AXUIElement,
    _ event: CFString,
    _ refcon: UnsafeMutableRawPointer?
) {
    guard let refcon else {
        return
    }
    let element = Unmanaged<AnyObject>.fromOpaque(refcon).takeUnretainedValue() as! SenseElement
    
    RootSenseElement.current?.objectWillChange.send()
    element.handleAxEvent(event: event)
}

class RootSenseElement: ObservableObject, SenseElement {
    var axElement: AXUIElement?
    
    @Published var focused: Bool = false
    var frame: CGRect = .zero
    
    static var current: RootSenseElement?
    
    private var observer: AXObserver?
    
    @Published var focusedWindow: (any SenseElement)?
    var processIdentifier: pid_t? {
        willSet {
            guard let processIdentifier else {
                return
            }

            self.observer = nil
            AXObserverCreate(
                processIdentifier,
                rootObserverCallback,
                &self.observer
            )
            
            guard let observer else {
                return
            }
            CFRunLoopAddSource(
                CFRunLoopGetCurrent(),
                AXObserverGetRunLoopSource(observer),
                .defaultMode
            );
        }
    }
    var appElement: AXUIElement? {
        willSet {
            guard let appElement else {
                return
            }
            
            addAxCallback(
                for: "kAXFocusedWindowChangedNotification" as CFString,
                element: appElement,
                target: self
            )
            addAxCallback(
                for: "kAXWindowCreatedNotification" as CFString,
                element: appElement,
                target: self
            )
            addAxCallback(
                for: "kAXMainWindowChangedNotification" as CFString,
                element: appElement,
                target: self
            )
        }
    }
    
    init() {
        RootSenseElement.current = self
    }
    
    func handleFocusMove(direction: MoveFocusDirection) -> Bool {
        self.objectWillChange.send()
        return focusedWindow?.handleFocusMove(direction: direction) ?? true
    }
    
    func handleFocusNext() -> Bool {
        self.objectWillChange.send()
        return focusedWindow?.handleFocusNext() ?? true
    }
    
    func handleFocusPrev() -> Bool {
        self.objectWillChange.send()
        return focusedWindow?.handleFocusPrev() ?? true
    }
    
    func handleFocus() {
        self.objectWillChange.send()
        self.focusedWindow?.handleFocus()
    }
    
    func handleUnfocus() {
        self.objectWillChange.send()
        self.focusedWindow?.handleUnfocus()
    }
    
    func handlePress() {
        self.focusedWindow?.handlePress()
    }
    
    var debugElements: [any SenseElement] {
        [
            focusedWindow
        ].compactMap { $0 }.flatMap { $0.debugElements }
    }
    
    func handleAxEvent(event: CFString) {
        print("handleAxEvent \(event)")
        self.objectWillChange.send()
        connectFocusedWindow()
    }
    
    func connectFocusedWindow() {
        guard let appElement else {
            return
        }
        guard let windowElement = appElement.attribute(kAXFocusedWindowAttribute) else {
            return
        }
        addAxCallback(
            for: "kAXUIElementDestroyedNotification" as CFString,
            element: windowElement as! AXUIElement,
            target: self
        )
        focusedWindow = visitChild(windowElement as! AXUIElement)
    }
    
    func addAxCallback(
        for event: CFString,
        element: AXUIElement,
        target: (any SenseElement)
    ) {
        guard let observer else {
            return
        }
        let refcon = UnsafeMutableRawPointer(Unmanaged.passRetained(target as AnyObject).toOpaque())
        
        AXObserverAddNotification(
            observer,
            element,
            event,
            refcon
        )
    }
    
    func handleScroll(x: CGFloat, y: CGFloat) {
        self.focusedWindow?.handleScroll(x: x, y: y)
    }
}
