import AppAdsFeature
import ComposableArchitecture
import MobileAdsClient
import PlayFeature
import PurchaseClient
import PurchaseFeature

public struct ApplicationEnvironment {
    internal let adsClient: MobileAdsClient
    internal let mainQueue: AnySchedulerOf<DispatchQueue>
    internal let purchaseClient: PurchaseClient
    
    public init(
        adsClient: MobileAdsClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        purchaseClient: PurchaseClient
    ) {
        self.adsClient = adsClient
        self.mainQueue = mainQueue
        self.purchaseClient = purchaseClient
    }
    
    internal var appAdsEnv: AppAdsEnvironment {
        AppAdsEnvironment(
            adsClient: adsClient
        )
    }
    
    internal var playEnv: PlayEnvironment {
        PlayEnvironment(
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
