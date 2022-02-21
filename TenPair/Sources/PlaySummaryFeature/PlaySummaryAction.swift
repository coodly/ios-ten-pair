import SwiftUI

public enum PlaySummaryAction {
    case onAppear
    
    case update(lines: Int, tiles: Int)
    
    case updateForeground(Color)
}
