import ComposableArchitecture
import PurchaseClient

public struct PurchaseEnvironment {
    internal let mainQueue: AnySchedulerOf<DispatchQueue>
    internal let purchaseClient: PurchaseClient
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        purchaseClient: PurchaseClient
    ) {
        self.mainQueue = mainQueue
        self.purchaseClient = purchaseClient
    }
}
