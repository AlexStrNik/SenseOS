//
//  ColumnSenseElement.swift
//  SenseOS
//
//  Created by Aleksandr Strizhnev on 14.01.2025.
//

class ColumnSenseElement: GroupSenseElement {
    override func handleFocusMove(direction: MoveFocusDirection) -> Bool {
        if direction != .up && direction != .down {
            return false
        }
        
        return super.handleFocusMove(direction: direction)
    }
}
