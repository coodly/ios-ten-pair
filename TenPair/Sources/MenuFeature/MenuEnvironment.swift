import ComposableArchitecture
import PurchaseClient
import PurchaseFeature
import RestartFeature

public struct MenuEnvironment {
    private let mainQueue: AnySchedulerOf<DispatchQueue>
    private let purchaseClient: PurchaseClient
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        purchaseClient: PurchaseClient
    ) {
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
