@Observable
class RootSenseElement: SenseElement {
    var axElement: AXUIElement?
    var focused: Bool = false
    var frame: CGRect = .zero
    
    var child: (any SenseElement)?
    
    init(child: (any SenseElement)?) {
        self.frame = .zero
        self.child = child
    }
    
    func handleFocusMove(direction: MoveFocusDirection) -> Bool {
        return child?.handleFocusMove(direction: direction) ?? true
    }
    
    func handleFocus() {
        self.child?.handleFocus()
    }
    
    func handleUnfocus() {
        self.child?.handleUnfocus()
    }
    
    func handlePress() {
        self.child?.handlePress()
    }
    
    var debugElements: [any SenseElement] {
        [
            child
        ].compactMap { $0 }.flatMap { $0.debugElements }
    }
}