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

import Foundation
import Purchases

internal class RevenueCatPurchase: NSObject, PurchasesDelegate {
    internal static let shared = RevenueCatPurchase()
    
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
    }
}
