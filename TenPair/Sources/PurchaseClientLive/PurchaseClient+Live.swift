import Combine
import Config
import Dependencies
import Foundation
import Logging
import ObjectiveC
import PurchaseClient
import RevenueCat

extension PurchaseClient: DependencyKey {
    public static var liveValue: PurchaseClient {
        let proxy = PurchasesProxy()
        
        return PurchaseClient(
            havePurchase: true,
            onAvailableProduct: proxy.loadProduct,
            onLoad: {
                Log.purchase.debug("Load")
                if AppConfig.current.logs {
                    Purchases.logLevel = .debug
                }
                Purchases.configure(withAPIKey: RevenueCatAPIKey)
                Purchases.shared.delegate = proxy
            },
            onPurchase: proxy.purchase,
            onPurchaseStatus: { proxy.purchaseStatus.receive(on: DispatchQueue.main).eraseToAnyPublisher() },
            onRestore: proxy.restorePurchases
        )
    }
}

private class PurchasesProxy: NSObject, PurchasesDelegate {
    fileprivate let purchaseStatus = CurrentValueSubject<PurchaseStatus, Never>(.notLoaded)
    private var package: Package?
    
    private func handle(info: CustomerInfo?) {
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

    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        handle(info: customerInfo)
    }
    
    fileprivate func loadProduct() async throws -> AppProduct {
        let offerings = try await Purchases.shared.offerings()
        Log.purchase.debug("Loded offerings")
        Log.purchase.debug(offerings.current?.lifetime?.localizedPriceString)
        Log.purchase.debug(offerings.offering(identifier: "com.coodly.ten.pair.full.version")?.lifetime?.localizedPriceString)
        
        guard let loaded = offerings.current?.lifetime ?? offerings.offering(identifier: "com.coodly.ten.pair.full.version")?.lifetime else {
            throw PurchaseError.noProducts
        }
        
        self.package = loaded
        
        return AppProduct(identifier: loaded.identifier, formattedPrice: loaded.localizedPriceString)
    }
    
    fileprivate func purchase() async throws -> Bool {
        precondition(package != nil)
        
        let (_, info, cancelled) = try await Purchases.shared.purchase(package: package!)
        self.handle(info: info)
        return !cancelled
    }
    
    fileprivate func restorePurchases() async throws -> Bool {
        let info = try await Purchases.shared.restorePurchases()
        self.handle(info: info)
        return true
    }
}
