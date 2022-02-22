public enum ProductStatus: String {
    case loading
    case loaded
    case failure
}


public struct PurchaseState: Equatable {
    public var purchaseMade = false
    public var purchasePrice = "-"
    public var productStatus = ProductStatus.loading
    public var purchaseFailureMessage: String?
    public var purchaseInProgress = false
    
    public init() {
        
    }
}
