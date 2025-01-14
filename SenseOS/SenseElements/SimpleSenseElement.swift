//
//  SimpleSenseElement.swift
//  SenseOS
//
//  Created by Aleksandr Strizhnev on 14.01.2025.
//

import ApplicationServices

class SimpleSenseElement: ObservableObject, SenseElement {
    var axElement: AXUIElement?
    
    @Published var focused: Bool = false
    var frame: CGRect {
        axElement!.frame
    }
    
    init(axElement: AXUIElement) {
        self.axElement = axElement
    }
    
    func handleFocusMove(direction: MoveFocusDirection) -> Bool {
        return false
    }
    
    func handleFocusNext() -> Bool {
        return false
    }
    
    func handleFocusPrev() -> Bool {
        return false
    }
    
    func handleFocus() {
        self.focused = true
    }
    
    func handleUnfocus() {
        self.focused = false
    }
    
    var debugElements: [any SenseElement] {
        [
            self
        ]
    }
    
    func handlePress() {
        guard let axElement else { return }
        
        AXUIElementPerformAction(axElement, kAXPressAction as CFString)
    }
    
    func handleScroll(x: CGFloat, y: CGFloat) {
        
    }
    
    func handleAxEvent(event: CFString) {
        
    }
}
