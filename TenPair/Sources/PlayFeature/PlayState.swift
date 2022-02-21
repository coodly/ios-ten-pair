import MenuFeature
import PlaySummaryFeature

public enum RestartAction: Equatable {
    case regular
    case random(Int)
}

public struct PlayState: Equatable {
    public var menuState: MenuState?
    public var playSummaryState = PlaySummaryState()
    
    public var restartAction: RestartAction?
    
    public init() {
        
    }
}
