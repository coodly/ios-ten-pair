import PurchaseClient

public struct PurchaseEnvironment {
    internal let purchaseClient: PurchaseClient
    public init(
        purchaseClient: PurchaseClient
    ) {
        self.purchaseClient = purchaseClient
    }
}
