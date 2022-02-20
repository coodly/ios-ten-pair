import PurchaseClient

extension PurchaseClient {
    public static var live: PurchaseClient {
        PurchaseClient(
            havePurchase: true
        )
    }
}
