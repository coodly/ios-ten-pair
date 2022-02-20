public struct PurchaseClient {
    public let havePurchase: Bool
    public init(havePurchase: Bool) {
        self.havePurchase = havePurchase
    }
}

extension PurchaseClient {
    public static let noPurchase = PurchaseClient(
        havePurchase: false
    )
}
