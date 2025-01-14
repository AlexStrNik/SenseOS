@Observable
class SimpleSenseElement: SenseElement {
    var axElement: AXUIElement?
    var focused: Bool = false
    var frame: CGRect = .zero
    
    init(axElement: AXUIElement) {
        self.axElement = axElement
        self.frame = axElement.frame
    }
    
    func handleFocusMove(direction: MoveFocusDirection) -> Bool {
        return false
    }
    
    func handleFocus() {
        self.focused = true
        print("Focused \(axElement?.description)")
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
}
