import AppAdsFeature
import ComposableArchitecture
import PlayFeature
import PurchaseClient
import PurchaseFeature

public struct ApplicationEnvironment {
    internal let mainQueue: AnySchedulerOf<DispatchQueue>
    internal let purchaseClient: PurchaseClient
    
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        purchaseClient: PurchaseClient
    ) {
        self.mainQueue = mainQueue
        self.purchaseClient = purchaseClient
    }
    
    internal var appAdsEnv: AppAdsEnvironment {
        AppAdsEnvironment()
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
