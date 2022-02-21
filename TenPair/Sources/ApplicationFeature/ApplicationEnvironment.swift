import AppAdsFeature
import ComposableArchitecture
import PlayFeature
import PurchaseClient
import PurchaseFeature

public struct ApplicationEnvironment {
    private let mainQueue: AnySchedulerOf<DispatchQueue>
    private let purchaseClient: PurchaseClient
    
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
            mainQueue: mainQueue
        )
    }
    
    internal var purchaseEnv: PurchaseEnvironment {
        PurchaseEnvironment(
            purchaseClient: purchaseClient
        )
    }
}
