@preconcurrency import Combine
import ConcurrencyExtras
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
        let isolatedProxy = ActorIsolated(proxy)
        let isolatedPackage = ActorIsolated(Package.notLoaded)
        
        return PurchaseClient(
            havePurchase: true,
            onAvailableProduct: {
                let offerings = try await Purchases.shared.offerings()
                Log.purchase.debug("Loded offerings")
                Log.purchase.debug(offerings.current?.lifetime?.localizedPriceString)
                Log.purchase.debug(offerings.offering(identifier: "com.coodly.ten.pair.full.version")?.lifetime?.localizedPriceString)
                
                guard let loaded = offerings.current?.lifetime ?? offerings.offering(identifier: "com.coodly.ten.pair.full.version")?.lifetime else {
                    throw PurchaseError.noProducts
                }
                
                await isolatedPackage.setValue(loaded)
                
                return AppProduct(identifier: loaded.identifier, formattedPrice: loaded.localizedPriceString)
            },
            onLoad: {
                Log.purchase.debug("Load")
                if AppConfig.current.logs {
                    Purchases.logLevel = .debug
                }
                Purchases.configure(withAPIKey: RevenueCatAPIKey)
                Purchases.shared.delegate = proxy
            },
            onPurchase: {
                let package = await isolatedPackage.value
                precondition(package != Package.notLoaded)
                
                let (_, info, cancelled) = try await Purchases.shared.purchase(package: package)
                await isolatedProxy.value.handle(info: info)
                return !cancelled
            },
            onPurchaseStatus: { proxy.purchaseStatus.receive(on: DispatchQueue.main).eraseToAnyPublisher() },
            onRestore: {
                let info = try await Purchases.shared.restorePurchases()
                await isolatedProxy.value.handle(info: info)
                return true
            }
        )
    }
}

private final class PurchasesProxy: NSObject, PurchasesDelegate, Sendable {
    fileprivate let purchaseStatus = CurrentValueSubject<PurchaseStatus, Never>(.notLoaded)
    
    fileprivate func handle(info: CustomerInfo?) {
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
}

extension Package {
    fileprivate static let notLoaded = Package(
        identifier: "xx-not-loaded-xx",
        packageType: .custom,
        storeProduct: StoreProduct(sk1Product: SK1Product()),
        offeringIdentifier: "xx-not-loaded-xx"
    )
}

extension PurchaseStatus {
    fileprivate init(info: CustomerInfo) {
        if let date = info.purchaseDate(forEntitlement: "com.coodly.ten.pair.remove.ads") {
            Log.purchase.debug("Ads removed on \(date)")
            self = .made
        } else {
            Log.purchase.debug("Purchase not made")
            self = .notMade
        }
    }
}
