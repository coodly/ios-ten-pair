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
    let isolatedPackage = LockIsolated(Package.notLoaded)
        
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
                
        isolatedPackage.setValue(loaded)
                
        return AppProduct(identifier: loaded.identifier, formattedPrice: loaded.localizedPriceString)
      },
      onLoad: {
        Log.purchase.debug("Load")
        if AppConfig.current.logs {
          Purchases.logLevel = .debug
        }
        Purchases.configure(withAPIKey: RevenueCatAPIKey)
      },
      onPurchase: {
        let package = isolatedPackage.value
        precondition(package != Package.notLoaded)
                
        let (_, _, cancelled) = try await Purchases.shared.purchase(package: package)
        return !cancelled
      },
      onPurchaseStatusStream: { Purchases.shared.customerInfoStream.map({ PurchaseStatus(info: $0) }).eraseToStream() },
      onRestore: {
        let _ = try await Purchases.shared.restorePurchases()
        return true
      }
    )
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
