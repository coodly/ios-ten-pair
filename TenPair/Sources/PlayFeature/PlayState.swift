import MenuFeature
import PlaySummaryFeature

public struct PlayState: Equatable {
    public var menuState: MenuState?
    public var playSummaryState = PlaySummaryState()
    
    public init() {
        
    }
}
