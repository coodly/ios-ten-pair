import PurchaseClient
import PurchaseFeature
import RestartFeature

public struct MenuEnvironment {
    private let purchaseClient: PurchaseClient
    public init(purchaseClient: PurchaseClient) {
        self.purchaseClient = purchaseClient
    }
    
    internal var purchaseEnv: PurchaseEnvironment {
        PurchaseEnvironment(
            purchaseClient: purchaseClient
        )
    }
    
    internal var restartEnv: RestartEnvironment {
        RestartEnvironment()
    }
}
