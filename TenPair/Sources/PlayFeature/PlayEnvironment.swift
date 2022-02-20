import MenuFeature
import PlaySummaryFeature

public struct PlayEnvironment {
    public init() {
        
    }
    
    internal var menuEnv: MenuEnvironment {
        MenuEnvironment()
    }
    
    internal var playSummaryEnv: PlaySummaryEnvironment {
        PlaySummaryEnvironment()
    }
}
