//
//  ScrollSenseElement.swift
//  SenseOS
//
//  Created by Aleksandr Strizhnev on 14.01.2025.
//

import ApplicationServices

class ScrollSenseElement: GroupSenseElement {
    private var axBar: AXUIElement?
    private var timer: Timer?
    private var speed: CGFloat = 0
    
    var isVertical: Bool {
        axElement?.attribute("AXVerticalScrollBar") != nil
    }
    
    override init(axElement: AXUIElement, elements: [any SenseElement]) {
        super.init(axElement: axElement, elements: elements)
        self.axBar = axElement.children!.first { $0.role == kAXScrollBarRole }
    }
    
    override func handleScroll(x: CGFloat, y: CGFloat) {
        if isVertical {
            setScrollSpeed(y)
        } else {
            setScrollSpeed(x)
        }
    }
    
    private func setScrollSpeed(_ speed: CGFloat) {
        self.speed = speed
        if speed != 0 {
            timer = Timer.scheduledTimer(
                timeInterval: 0.01,
                target: self,
                selector: #selector(repeatScroll),
                userInfo: nil,
                repeats: true
            )
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc func repeatScroll() {
        guard let axBar else { return }

        guard let oldValue = axBar.attribute("AXValue"), let oldValue = oldValue as? CGFloat else {
            return
        }

        let value = oldValue - speed * 0.0005 as AnyObject
        
        AXUIElementSetAttributeValue(
            axBar,
            "AXValue" as CFString,
            value
        )
    }
}
