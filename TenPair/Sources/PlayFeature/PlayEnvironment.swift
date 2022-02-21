import ComposableArchitecture
import MenuFeature
import PlaySummaryFeature
import PurchaseClient

public struct PlayEnvironment {
    private let mainQueue: AnySchedulerOf<DispatchQueue>
    internal let purchaseClient: PurchaseClient
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        purchaseClient: PurchaseClient
    ) {
        self.mainQueue = mainQueue
        self.purchaseClient = purchaseClient
    }
    
    internal var menuEnv: MenuEnvironment {
        MenuEnvironment(
            purchaseClient: purchaseClient
        )
    }
    
    internal var playSummaryEnv: PlaySummaryEnvironment {
        PlaySummaryEnvironment(mainQueue: mainQueue)
    }
}
