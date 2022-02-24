import CloudMessagesClient
import ComposableArchitecture
import PurchaseClient
import PurchaseFeature
import RateAppClient
import RestartFeature
import SendFeedbackFeature

public struct MenuEnvironment {
    internal let cloudMessages: CloudMessagesClient
    internal let mainQueue: AnySchedulerOf<DispatchQueue>
    private let purchaseClient: PurchaseClient
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
    
    internal var purchaseEnv: PurchaseEnvironment {
        PurchaseEnvironment(
            mainQueue: mainQueue,
            purchaseClient: purchaseClient,
            rateAppClient: rateAppClient
        )
    }
    
    internal var restartEnv: RestartEnvironment {
        RestartEnvironment()
    }
    
    internal var sendFeedbackEnv: SendFeedbackEnvironment {
        SendFeedbackEnvironment(
            cloudMessagesClient: cloudMessages,
            mainQueue: mainQueue
        )
    }
}
