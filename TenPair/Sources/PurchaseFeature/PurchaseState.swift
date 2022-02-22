public enum ProductStatus: String {
    case loading
    case loaded
    case failure
}

public enum PurchaseMode {
    case showing
    case purchaseInProgress
    case restoreInProgress
}

public struct PurchaseState: Equatable {
    public var purchaseMade = false
    public var purchasePrice = "-"
    public var productStatus = ProductStatus.loading
    public var purchaseFailureMessage: String?
    public var purchaseInProgress: Bool {
        purchaseMode == .purchaseInProgress
    }
    public var restoreInProgress: Bool {
        purchaseMode == .restoreInProgress
    }
    public var purchaseMode = PurchaseMode.showing
    
    public init() {
        
    }
}
