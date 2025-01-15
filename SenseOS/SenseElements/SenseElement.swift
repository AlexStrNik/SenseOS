//
//  SenseElement.swift
//  SenseOS
//
//  Created by Aleksandr Strizhnev on 14.01.2025.
//

import ApplicationServices

protocol SenseElement {
    var focused: Bool { get set }
    var frame: CGRect { get }
    var axElement: AXUIElement? { get }
    
    var debugElements: [any SenseElement] { get }
    
    func handleFocusMove(direction: MoveFocusDirection) -> Bool
    
    func handleFocusPrev() -> Bool
    
    func handleFocusNext() -> Bool
    
    func handleFocus()
    
    func handleUnfocus()
    
    func handlePress()
    
    func handleScroll(x: CGFloat, y: CGFloat)
    
    func handleAxEvent(event: CFString)
}

func visitChild(_ element: AXUIElement) -> (any SenseElement)? {
    switch element.role {
    case "AXSplitGroup":
        return GroupSenseElement(
            axElement: element,
            elements: visitCollection(element)
        )
    case "AXGroup":
        return GroupSenseElement(
            axElement: element,
            elements: visitCollection(element)
        )
    case "AXSheet":
        return GroupSenseElement(
            axElement: element,
            elements: visitCollection(element)
        )
    case "AXRadioGroup":
        return GroupSenseElement(
            axElement: element,
            elements: visitCollection(element)
        )
    case "AXOpaqueProviderGroup":
        return GroupSenseElement(
            axElement: element,
            elements: visitCollection(element)
        )
    case "AXWindow":
        return GroupSenseElement(
            axElement: element,
            elements: visitCollection(element)
        )
    case "AXList":
        return GroupSenseElement(
            axElement: element,
            elements: visitCollection(element)
        )
    case "AXTabGroup":
        return GroupSenseElement(
            axElement: element,
            elements: visitCollection(element)
        )
    case "AXOutline":
        return OutlineSenseElement(
            axElement: element,
            elements: visitCollection(element)
        )
    case "AXColumn":
        return ColumnSenseElement(
            axElement: element,
            elements: visitCollection(element)
        )
    case "AXRow":
        return RowSenseElement(
            axElement: element
        )
    case "AXToolbar":
        return GroupSenseElement(
            axElement: element,
            elements: visitCollection(element)
        )
    case "AXRadioButton":
        return SimpleSenseElement(
            axElement: element
        )
    case "AXMenuButton":
        return SimpleSenseElement(
            axElement: element
        )
    case "AXScrollArea":
        return ScrollSenseElement(
            axElement: element,
            elements: visitCollection(element)
        )
    case "AXButton":
        return SimpleSenseElement(
            axElement: element
        )
    case "AXCheckBox":
        return SimpleSenseElement(
            axElement: element
        )
    case "AXSlider":
        return SliderSenseElement(
            axElement: element
        )
    default:
        print("Unsupported role: \(element.role ?? "unknown")")
        return nil
    }
}

func visitCollection(_ element: AXUIElement) -> [any SenseElement] {
    return (element.attribute("AXChildrenInNavigationOrder") as? [AXUIElement] ?? []).compactMap(visitChild)
}
