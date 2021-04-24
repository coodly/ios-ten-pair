/*
 * Copyright 2020 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Combine
import Config
import Foundation
import Logging
import Purchases

internal enum ShowAdsStatus: String {
    case unknown
    case removed
    case show
}

internal enum PurchaseError: LocalizedError {
    case noProducts
}

public protocol TenPairProduct {
    var localizedPrice: String { get }
    var identifier: String { get }
}

internal class RevenueCatPurchase: NSObject, PurchasesDelegate {
    internal static let shared = RevenueCatPurchase()

    private(set) internal var adsStatus = CurrentValueSubject<ShowAdsStatus, Never>(ShowAdsStatus.unknown)

    private override init() {}
    
    internal func load() {
        Log.purchase.debug("Load")
        if AppConfig.current.logs {
            Purchases.debugLogsEnabled = true
        }
        Purchases.configure(withAPIKey: RevenueCatAPIKey)
        Purchases.shared.delegate = self
        
        checkReceipt()
    }
    
    private func checkReceipt() {
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
            adsStatus.send(.removed)
        } else {
            adsStatus.send(.show)
        }
    }
    
    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
        handle(info: purchaserInfo)
    }
    
    func product() -> AnyPublisher<TenPairProduct, Error> {
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
                
                guard let removeAds: TenPairProduct =
                        offerings?.current?.lifetime ?? offerings?.offering(identifier: "com.coodly.ten.pair.full.version")?.lifetime else {
                    promise(.failure(PurchaseError.noProducts))
                    return
                }
                
                promise(.success(removeAds))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func restorePurchases() -> AnyPublisher<Bool, Error> {
        Future() {
            promise in
            
            Purchases.shared.restoreTransactions() {
                info, error in

                
                self.handle(info: info)
                
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(true))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func purchase(_ product: TenPairProduct) -> AnyPublisher<Bool, Error> {
        let package = product as! Purchases.Package
        
        return Future() {
            promise in
            
            Purchases.shared.purchasePackage(package) {
                transaction, info, error, cancelled in
                
                self.handle(info: info)
                
                if let error = error {
                    Log.purchase.error("Purchase error \(error)")
                    promise(.failure(error))
                } else {
                    promise(.success(true))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Purchases.Package: TenPairProduct {
    public var localizedPrice: String {
        localizedPriceString
    }
}
