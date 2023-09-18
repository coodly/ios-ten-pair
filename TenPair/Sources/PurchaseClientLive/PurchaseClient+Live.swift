import Config
import Dependencies
import Logging
import PurchaseClient
import Purchases
import Combine

extension PurchaseClient: DependencyKey {
    public static var liveValue: PurchaseClient {
        .live
    }
}

extension PurchaseClient {
    public static var live: PurchaseClient {
        let proxy = PurchasesProxy()
        
        return PurchaseClient(
            havePurchase: true,
            onAvailableProduct: proxy.product,
            onLoad: {
                Log.purchase.debug("Load")
                if AppConfig.current.logs {
                    Purchases.logLevel = .debug
                }
                Purchases.configure(withAPIKey: RevenueCatAPIKey)
                Purchases.shared.delegate = proxy
                
                proxy.checkReceipt()
            },
            onPurchase: proxy.purchase,
            onPurchaseStatus: {
                proxy.purchaseStatus.eraseToAnyPublisher()
            },
            onRestore: proxy.restorePurchases
        )
    }
}

private class PurchasesProxy: NSObject, PurchasesDelegate {
    fileprivate let purchaseStatus = CurrentValueSubject<PurchaseStatus, Never>(.notLoaded)
    private var package: Purchases.Package?
    
    fileprivate func checkReceipt() {
        Purchases.shared.purchaserInfo() {
            info, error in
            
            if let error = error {
                Log.purchase.error("Check receipt error: \(error)")
            } else {
                self.handle(info: info)
            }
        }
    }

    private func handle(info: Purchases.PurchaserInfo?) {
        guard let info = info else {
            return
        }
        
        Log.purchase.debug("Info \(info)")
        if let date = info.purchaseDate(forEntitlement: "com.coodly.ten.pair.remove.ads") {
            Log.purchase.debug("Ads removed on \(date)")
            purchaseStatus.send(.made)
        } else {
            Log.purchase.debug("Purchase not made")
            purchaseStatus.send(.notMade)
        }
    }
    
    fileprivate func product() async throws -> AppProduct {
        return try await withCheckedThrowingContinuation {
            continuation in
            
            Purchases.shared.offerings() {
                offerings, error in
                
                if let error = error {
                    Log.purchase.error("Get offerings error: \(error)")
                    continuation.resume(with: .failure(error))
                    return
                }
                
                Log.purchase.debug("Loded offerings")
                Log.purchase.debug(offerings?.current?.lifetime?.localizedPriceString)
                Log.purchase.debug(offerings?.offering(identifier: "com.coodly.ten.pair.full.version")?.lifetime?.localizedPriceString)
                
                guard let loaded = offerings?.current?.lifetime ?? offerings?.offering(identifier: "com.coodly.ten.pair.full.version")?.lifetime else {
                    continuation.resume(with: .failure(PurchaseError.noProducts))
                    return
                }
                
                self.package = loaded
                
                let product = AppProduct(identifier: loaded.identifier, formattedPrice: loaded.localizedPriceString, product: loaded.product)
                continuation.resume(with: .success(product))
            }
        }
    }
    
    fileprivate func restorePurchases() async throws -> Bool {
        return try await withCheckedThrowingContinuation {
            continuation in
            
            Purchases.shared.restoreTransactions() {
                info, error in

                
                self.handle(info: info)
                
                continuation.resume(with: .success(true))
            }
        }
    }
    
    fileprivate func purchase() async throws -> Bool {
        precondition(package != nil)
        
        return try await withCheckedThrowingContinuation {
            continuation in
            
            Purchases.shared.purchasePackage(self.package!) {
                transaction, info, error, cancelled in
                
                self.handle(info: info)
                
                if let error = error, !cancelled {
                    Log.purchase.error("Purchase error \(error)")
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(with: .success(!cancelled))
                }
            }
        }
    }

    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
        handle(info: purchaserInfo)
    }
}
