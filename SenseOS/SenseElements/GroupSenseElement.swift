@Observable
class GroupSenseElement: SenseElement {
    var axElement: AXUIElement?
    var focused: Bool = false
    var elements: [any SenseElement] = []
    
    private var lastFocusedElement: (any SenseElement)?
    
    var frame: CGRect = .zero
    
    init(axElement: AXUIElement, elements: [any SenseElement]) {
        self.axElement = axElement
        self.frame = axElement.frame
        self.elements = elements
    }
    
    private var focusedChild: (any SenseElement)? {
        elements.first(where: \.focused)
    }
    
    private var focusedIndex: Int? {
        elements.firstIndex(where: \.focused)
    }
    
    func handleFocusMove(direction: MoveFocusDirection) -> Bool {
        guard let focusedChild = focusedChild else {
            return false
        }
        if focusedChild.handleFocusMove(direction: direction) {
            return true
        }
        
        let nextElement = getNextFocusableElement(from: focusedChild, in: direction)
        guard let nextElement else {
            return false
        }
        
        focusedChild.handleUnfocus()
        nextElement.handleFocus()
        
        return true
    }
    
    private func getNextFocusableElement(
        from element: any SenseElement,
        in direction: MoveFocusDirection
    ) -> (any SenseElement)? {
        let index = focusedIndex!
        
        switch direction {
        case .right:
            if index + 1 < self.elements.count && self.elements[index + 1].frame.midX > element.frame.midX {
                return self.elements[index + 1]
            }
            
            return self.elements.first {
                $0.frame.midX > element.frame.midX
            }
        case .left:
            if index - 1 > 0 && self.elements[index - 1].frame.midX < element.frame.midX {
                return self.elements[index - 1]
            }
            
            return self.elements.last {
                $0.frame.midX < element.frame.midX
            }
        case .down:
            return self.elements.first {
                $0.frame.midY > element.frame.midY
            }
        case .up:
            return self.elements.last {
                $0.frame.midY < element.frame.midY
            }
        }
    }
    
    func handleFocus() {
        self.focused = true
        (lastFocusedElement ?? self.elements.first)?.handleFocus()
    }
    
    func handleUnfocus() {
        lastFocusedElement = focusedChild
        self.focused = false
        self.elements.forEach { $0.handleUnfocus() }
    }
    
    func handlePress() {
        self.focusedChild?.handlePress()
    }
    
    var debugElements: [any SenseElement] {
        [self] + elements.flatMap(\.debugElements)
    }
}