import AppAdsFeature
import PurchaseFeature

public struct ApplicationEnvironment {
    public init() {
        
    }
    
    internal var appAdsEnv: AppAdsEnvironment {
        AppAdsEnvironment()
    }
    
    internal var purchaseEnv: PurchaseEnvironment {
        PurchaseEnvironment()
    }
}
