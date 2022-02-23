import AppAdsFeature
import CloudMessagesClient
import ComposableArchitecture
import MobileAdsClient
import PlayFeature
import PurchaseClient
import PurchaseFeature

public struct ApplicationEnvironment {
    internal let adsClient: MobileAdsClient
    private let cloudMessages: CloudMessagesClient
    internal let mainQueue: AnySchedulerOf<DispatchQueue>
    internal let purchaseClient: PurchaseClient
    
    public init(
        adsClient: MobileAdsClient,
        cloudMessages: CloudMessagesClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        purchaseClient: PurchaseClient
    ) {
        self.adsClient = adsClient
        self.cloudMessages = cloudMessages
        self.mainQueue = mainQueue
        self.purchaseClient = purchaseClient
    }
    
    internal var appAdsEnv: AppAdsEnvironment {
        AppAdsEnvironment(
            adsClient: adsClient,
            mainQueue: mainQueue
        )
    }
    
    internal var playEnv: PlayEnvironment {
        PlayEnvironment(
            cloudMessages: cloudMessages,
            mainQueue: mainQueue,
            purchaseClient: purchaseClient
        )
    }
    
    internal var purchaseEnv: PurchaseEnvironment {
        PurchaseEnvironment(
            mainQueue: mainQueue,
            purchaseClient: purchaseClient
        )
    }
}
