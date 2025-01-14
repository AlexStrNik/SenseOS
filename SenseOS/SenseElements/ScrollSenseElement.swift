class ScrollSenseElement: SenseElement {
    var axElement: AXUIElement?
    var focused: Bool = false
    var child: any SenseElement
    
    var frame: CGRect = .zero
    
    init(axElement: AXUIElement, child: SenseElement) {
        self.axElement = axElement
        self.frame = axElement.frame
        self.child = child
    }
    
    func handleFocusMove(direction: MoveFocusDirection) -> Bool {
        self.child.handleFocusMove(direction: direction)
    }
    
    func handleFocus() {
        self.focused = true
        self.child.handleFocus()
    }
    
    func handleUnfocus() {
        self.focused = false
        self.child.handleUnfocus()
    }
    
    func handlePress() {
        self.child.handlePress()
    }
    
    var debugElements: [any SenseElement] {
        [self] + child.debugElements
    }
}