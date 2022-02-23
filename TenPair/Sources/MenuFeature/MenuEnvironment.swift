import CloudMessagesClient
import ComposableArchitecture
import PurchaseClient
import PurchaseFeature
import RestartFeature

public struct MenuEnvironment {
    private let cloudMessages: CloudMessagesClient
    private let mainQueue: AnySchedulerOf<DispatchQueue>
    private let purchaseClient: PurchaseClient
    public init(
        cloudMessages: CloudMessagesClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        purchaseClient: PurchaseClient
    ) {
        self.cloudMessages = cloudMessages
        self.mainQueue = mainQueue
        self.purchaseClient = purchaseClient
    }
    
    internal var purchaseEnv: PurchaseEnvironment {
        PurchaseEnvironment(
            mainQueue: mainQueue,
            purchaseClient: purchaseClient
        )
    }
    
    internal var restartEnv: RestartEnvironment {
        RestartEnvironment()
    }
}
