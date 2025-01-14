//
//  GroupSenseElement.swift
//  SenseOS
//
//  Created by Aleksandr Strizhnev on 14.01.2025.
//

import ApplicationServices

class GroupSenseElement: ObservableObject, SenseElement {
    var axElement: AXUIElement?
    @Published var focused: Bool = false
    
    @Published var elements: [any SenseElement] = [] {
        didSet {
            for element in elements {
                guard let axElement = element.axElement else { continue }
                
                RootSenseElement.current?.addAxCallback(
                    for: kAXUIElementDestroyedNotification as CFString,
                    element: axElement,
                    target: self
                )
            }
        }
    }
    
    var frame: CGRect {
        axElement!.frame
    }
    
    init(axElement: AXUIElement, elements: [any SenseElement]) {
        self.axElement = axElement
        self.elements = elements
        
        RootSenseElement.current?.addAxCallback(
            for: kAXLayoutChangedNotification as CFString,
            element: axElement,
            target: self
        )
    }
    
    @Published var focusedIndex: Int? = nil
    
    func handleFocusMove(direction: MoveFocusDirection) -> Bool {
        guard let focusedIndex, focusedIndex < self.elements.count else {
            return false
        }
        if self.elements[focusedIndex].handleFocusMove(direction: direction) {
            return true
        }
        
        let nextElement = getNextFocusableElement(from: focusedIndex, in: direction)
        guard let nextElement else {
            return false
        }
        
        self.elements[focusedIndex].handleUnfocus()
        self.elements[nextElement].handleFocus()
        self.focusedIndex = nextElement
        
        return true
    }
    
    func handleFocusNext() -> Bool {
        guard let focusedIndex, focusedIndex < self.elements.count else {
            return false
        }
        if self.elements[focusedIndex].handleFocusNext() {
            return true
        }
        guard focusedIndex < self.elements.count - 1 else {
            return false
        }
        
        self.elements[focusedIndex].handleUnfocus()
        self.elements[focusedIndex + 1].handleFocus()
        self.focusedIndex = focusedIndex + 1
        
        return true
    }
    
    func handleFocusPrev() -> Bool {
        guard let focusedIndex, focusedIndex < self.elements.count else {
            return false
        }
        if self.elements[focusedIndex].handleFocusPrev() {
            return true
        }
        guard focusedIndex > 0 else {
            return false
        }
        
        self.elements[focusedIndex].handleUnfocus()
        self.elements[focusedIndex - 1].handleFocus()
        self.focusedIndex = focusedIndex - 1
        
        return true
    }
    
    private func getNextFocusableElement(
        from index: Int,
        in direction: MoveFocusDirection
    ) -> Int? {
        let element = self.elements[index]
        
        switch direction {
        case .right:
            if index + 1 < self.elements.count && self.elements[index + 1].frame.midX > element.frame.midX {
                return index + 1
            }
            
            return self.elements.firstIndex {
                $0.frame.midX > element.frame.midX
            }
        case .left:
            if index - 1 > 0 && self.elements[index - 1].frame.midX < element.frame.midX {
                return index - 1
            }
            
            return self.elements.lastIndex {
                $0.frame.midX < element.frame.midX
            }
        case .down:
            if index + 1 < self.elements.count && self.elements[index + 1].frame.midY > element.frame.midY {
                return index + 1
            }
            
            return self.elements.firstIndex {
                $0.frame.midY > element.frame.midY
            }
        case .up:
            if index - 1 > 0 && self.elements[index - 1].frame.midY < element.frame.midY {
                return index - 1
            }
            
            return self.elements.lastIndex {
                $0.frame.midY < element.frame.midY
            }
        }
    }
    
    func handleFocus() {
        self.focused = true
        
        focusedIndex = focusedIndex ?? 0
        
        guard focusedIndex! < self.elements.count else {
            return
        }
        self.elements[focusedIndex!].handleFocus()
    }
    
    func handleUnfocus() {
        self.focused = false
        self.elements.forEach { $0.handleUnfocus() }
    }
    
    func handlePress() {
        guard let focusedIndex, focusedIndex < self.elements.count else { return }
        
        self.elements[focusedIndex].handlePress()
    }
    
    func handleScroll(x: CGFloat, y: CGFloat) {
        guard let focusedIndex, focusedIndex < self.elements.count else { return }
        
        self.elements[focusedIndex].handleScroll(x: x, y: y)
    }
    
    var debugElements: [any SenseElement] {
        [self] + elements.flatMap(\.debugElements)
    }
    
    func handleAxEvent(event: CFString) {
        let newElements = visitCollection(self.axElement!)
        
        self.objectWillChange.send()
        self.elements = newElements
    }
}
