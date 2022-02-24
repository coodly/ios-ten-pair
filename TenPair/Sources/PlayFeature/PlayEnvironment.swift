import CloudMessagesClient
import ComposableArchitecture
import MenuFeature
import PlaySummaryFeature
import PurchaseClient
import RateAppClient

public struct PlayEnvironment {
    internal let cloudMessages: CloudMessagesClient
    private let mainQueue: AnySchedulerOf<DispatchQueue>
    internal let purchaseClient: PurchaseClient
    private let rateAppClient: RateAppClient
    public init(
        cloudMessages: CloudMessagesClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        purchaseClient: PurchaseClient,
        rateAppClient: RateAppClient
    ) {
        self.cloudMessages = cloudMessages
        self.mainQueue = mainQueue
        self.purchaseClient = purchaseClient
        self.rateAppClient = rateAppClient
    }
    
    internal var menuEnv: MenuEnvironment {
        MenuEnvironment(
            cloudMessages: cloudMessages,
            mainQueue: mainQueue,
            purchaseClient: purchaseClient,
            rateAppClient: rateAppClient
        )
    }
    
    internal var playSummaryEnv: PlaySummaryEnvironment {
        PlaySummaryEnvironment(mainQueue: mainQueue)
    }
}
