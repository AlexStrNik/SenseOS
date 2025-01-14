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
    
    init(processIdentifier: pid_t, child: (any SenseElement)?) {
        self.frame = .zero
        self.focusedWindow = child
        
        if processIdentifier == -1 {
            return
        }
        
        RootSenseElement.current = self
        
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
