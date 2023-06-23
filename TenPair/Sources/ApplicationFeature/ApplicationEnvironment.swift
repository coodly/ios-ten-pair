import AppAdsFeature
import CloudMessagesClient
import ComposableArchitecture
import Foundation
import MobileAdsClient
import PlayFeature
import PurchaseClient
import RateAppClient

public struct ApplicationEnvironment {
    internal let adsClient: MobileAdsClient
    internal let cloudMessages: CloudMessagesClient
    internal let mainQueue: AnySchedulerOf<DispatchQueue>
    internal let purchaseClient: PurchaseClient
    internal let rateAppClient: RateAppClient
    
    public init(
        adsClient: MobileAdsClient,
        cloudMessages: CloudMessagesClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        purchaseClient: PurchaseClient,
        rateAppClient: RateAppClient
    ) {
        self.adsClient = adsClient
        self.cloudMessages = cloudMessages
        self.mainQueue = mainQueue
        self.purchaseClient = purchaseClient
        self.rateAppClient = rateAppClient
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
            purchaseClient: purchaseClient,
            rateAppClient: rateAppClient
        )
    }
}
