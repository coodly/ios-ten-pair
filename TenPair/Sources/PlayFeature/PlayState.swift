import MenuFeature
import PlaySummaryFeature

public enum RestartAction: Equatable {
    case regular
    case random(Int)
}

public struct PlayState: Equatable {
    public var menuState: Menu.State?
    public var playSummaryState = PlaySummary.State()
    
    public var restartAction: RestartAction?
    
    public init() {
        
    }
}
