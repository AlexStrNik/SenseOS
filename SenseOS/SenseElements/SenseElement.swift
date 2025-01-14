protocol SenseElement {
    var focused: Bool { get set }
    var frame: CGRect { get }
    var axElement: AXUIElement? { get }
    
    var debugElements: [any SenseElement] { get }
    
    func handleFocusMove(direction: MoveFocusDirection) -> Bool
    
    func handleFocus()
    
    func handleUnfocus()
    
    func handlePress()
}