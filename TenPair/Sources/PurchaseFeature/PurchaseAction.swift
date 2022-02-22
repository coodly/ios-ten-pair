import PurchaseClient

public enum PurchaseAction {
    case onAppear
    case onDisappear
    
    case loadStatusMonitor
    case loadProduct
    
    case loadedProduct(Result<AppProduct, Error>)
    case statusChanged(Result<PurchaseStatus, Error>)
    
    case purchase
    case purchaseMade(Result<Bool, Error>)
    
    case restore
    case restoreMade(Result<Bool, Error>)
    
    case rateApp
}
