import Config
import Logging
import PurchaseClient
import Purchases
import Combine
import RemoveAds

extension PurchaseClient {
    public static var live: PurchaseClient {
        let proxy = PurchasesProxy()
        
        return PurchaseClient(
            havePurchase: true,
            onAvailableProduct: proxy.product,
            onLoad: {
                Log.purchase.debug("Load")
                if AppConfig.current.logs {
                    Purchases.debugLogsEnabled = true
                }
                Purchases.configure(withAPIKey: RevenueCatAPIKey)
                Purchases.shared.delegate = proxy
                
                proxy.checkReceipt()
            },
            onPurchase: {
                product in
                
                fatalError()
            },
            onPurchaseStatus: {
                fatalError()
            },
            onRestore: {
                fatalError()
            }
        )
    }
}

private class PurchasesProxy: NSObject, PurchasesDelegate {
    fileprivate let purchaseStatus = CurrentValueSubject<PurchaseStatus, Error>(.notLoaded)
    
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
            purchaseStatus.send(.notMade)
        }
    }
    
    fileprivate func product() -> AnyPublisher<AppProduct, Error> {
        Future() {
            promise in
            
            Purchases.shared.offerings() {
                offerings, error in
                
                if let error = error {
                    Log.purchase.error("Get offerings error: \(error)")
                    promise(.failure(error))
                    return
                }
                
                Log.purchase.debug("Loded offerings")
                Log.purchase.debug(offerings?.current?.lifetime?.localizedPriceString)
                Log.purchase.debug(offerings?.offering(identifier: "com.coodly.ten.pair.full.version")?.lifetime?.localizedPriceString)
                
                guard let loaded = offerings?.current?.lifetime ?? offerings?.offering(identifier: "com.coodly.ten.pair.full.version")?.lifetime else {
                    promise(.failure(PurchaseError.noProducts))
                    return
                }
                
                
                let product = AppProduct(identifier: loaded.identifier, formattedPrice: loaded.localizedPriceString, product: loaded.product)
                promise(.success(product))
            }
        }
        .eraseToAnyPublisher()
    }

    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
        handle(info: purchaserInfo)
    }
}
