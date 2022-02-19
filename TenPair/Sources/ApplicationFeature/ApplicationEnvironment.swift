import AppAdsFeature
import PlayFeature
import PurchaseClient
import PurchaseFeature

public struct ApplicationEnvironment {
    private let purchaseClient: PurchaseClient
    
    public init(
        purchaseClient: PurchaseClient
    ) {
        self.purchaseClient = purchaseClient
    }
    
    internal var appAdsEnv: AppAdsEnvironment {
        AppAdsEnvironment()
    }
    
    internal var playEnv: PlayEnvironment {
        PlayEnvironment()
    }
    
    internal var purchaseEnv: PurchaseEnvironment {
        PurchaseEnvironment(
            purchaseClient: purchaseClient
        )
    }
}
