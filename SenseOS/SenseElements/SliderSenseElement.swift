//
//  SliderSenseElement.swift
//  SenseOS
//
//  Created by Aleksandr Strizhnev on 15.01.2025.
//

import ApplicationServices

class SliderSenseElement: SimpleSenseElement {
    private var timer: Timer?
    private var speed: CGFloat = 0
    
    override func handleScroll(x: CGFloat, y: CGFloat) {
        setScrollSpeed(x)
    }
    
    private func setScrollSpeed(_ speed: CGFloat) {
        self.speed = speed
        if speed != 0 {
            timer?.invalidate()
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
        guard let oldValue = axElement!.attribute("AXValue"), let oldValue = oldValue as? CGFloat else {
            return
        }

        let value = oldValue + speed * 0.01 as AnyObject
        
        AXUIElementSetAttributeValue(
            axElement!,
            "AXValue" as CFString,
            value
        )
        
        print("repeatScroll")
    }
}
