//
//  RowSenseElement.swift
//  SenseOS
//
//  Created by Aleksandr Strizhnev on 14.01.2025.
//

import ApplicationServices

class RowSenseElement: SimpleSenseElement {
    override func handlePress() {
        super.handlePress()

        AXUIElementSetAttributeValue(
            axElement!,
            "AXSelected" as CFString,
            true as CFBoolean
        )
        
        AXUIElementPerformAction(axElement!, "AXPickAction" as CFString)
        AXUIElementPerformAction(axElement!, kAXPressAction as CFString)
    }
}
