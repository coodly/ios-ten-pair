import CloudMessagesClient
import ComposableArchitecture
import MenuFeature
import PlaySummaryFeature
import PurchaseClient

public struct PlayEnvironment {
    internal let cloudMessages: CloudMessagesClient
    private let mainQueue: AnySchedulerOf<DispatchQueue>
    internal let purchaseClient: PurchaseClient
    public init(
        cloudMessages: CloudMessagesClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        purchaseClient: PurchaseClient
    ) {
        self.cloudMessages = cloudMessages
        self.mainQueue = mainQueue
        self.purchaseClient = purchaseClient
    }
    
    internal var menuEnv: MenuEnvironment {
        MenuEnvironment(
            cloudMessages: cloudMessages,
            mainQueue: mainQueue,
            purchaseClient: purchaseClient
        )
    }
    
    internal var playSummaryEnv: PlaySummaryEnvironment {
        PlaySummaryEnvironment(mainQueue: mainQueue)
    }
}
