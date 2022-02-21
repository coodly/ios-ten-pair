import ComposableArchitecture
import MenuFeature
import PlaySummaryFeature

public struct PlayEnvironment {
    private let mainQueue: AnySchedulerOf<DispatchQueue>
    public init(mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.mainQueue = mainQueue
    }
    
    internal var menuEnv: MenuEnvironment {
        MenuEnvironment()
    }
    
    internal var playSummaryEnv: PlaySummaryEnvironment {
        PlaySummaryEnvironment(mainQueue: mainQueue)
    }
}
