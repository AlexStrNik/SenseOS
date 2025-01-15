//
//  GroupSenseElement.swift
//  SenseOS
//
//  Created by Aleksandr Strizhnev on 14.01.2025.
//

import CoreGraphics
import ApplicationServices

func distance(
    a: CGRect,
    b: CGRect,
    xScale: CGFloat = 1,
    yScale: CGFloat = 1
) -> CGFloat {
    return (pow(a.midX - b.midX, 2) * xScale + pow(a.midY - b.midY, 2) * yScale).squareRoot()
}

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
    
    private func closestWithPredicate(
        current: SenseElement,
        direction: MoveFocusDirection,
        _ predicate: (Int) -> Bool
    ) -> Int? {
        let (xScale, yScale) = switch (direction) {
        case .left, .right:
            (1.0, 500.0)
        case .up, .down:
            (500.0, 1.0)
        }
        
        return Array(
            elements.indices.filter(predicate)
        ).sorted {
            distance(
                a: elements[$0].frame,
                b: current.frame,
                xScale: xScale,
                yScale: yScale
            ) < distance(
                a: elements[$1].frame,
                b: current.frame,
                xScale: xScale,
                yScale: yScale
            )
        }
        .first
    }
    
    private func getNextFocusableElement(
        from index: Int,
        in direction: MoveFocusDirection
    ) -> Int? {
        let element = self.elements[index]
        
        switch direction {
        case .right:
            return closestWithPredicate(current: element, direction: direction) {
                elements[$0].frame.midX > element.frame.midX
            }
        case .left:
            return closestWithPredicate(current: element, direction: direction) {
                elements[$0].frame.midX < element.frame.midX
            }
        case .down:
            return closestWithPredicate(current: element, direction: direction) {
                elements[$0].frame.midY > element.frame.midY
            }
        case .up:
            return closestWithPredicate(current: element, direction: direction) {
                elements[$0].frame.midY < element.frame.midY
            }
        }
    }
    
    func handleFocus() {
        focusedIndex = focusedIndex ?? 0
        
        guard focusedIndex! < self.elements.count else {
            return
        }
        self.focused = true
        if let axElement {   
            AXUIElementSetAttributeValue(
                axElement,
                kAXFocusedAttribute as CFString,
                true as CFBoolean
            )
        }
        
        self.elements[focusedIndex!].handleFocus()
    }
    
    func handleUnfocus() {
        self.focused = false
        self.elements.forEach { $0.handleUnfocus() }
        
        guard let axElement else { return }
        
        AXUIElementSetAttributeValue(
            axElement,
            kAXFocusedAttribute as CFString,
            false as CFBoolean
        )
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
        self.handleFocus()
    }
}
