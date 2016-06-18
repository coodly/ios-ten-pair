/*
 * Copyright 2016 Coodly LLC
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

import StoreKit

public typealias ProductsResponse = ([SKProduct], [String]) -> ()

public protocol ProductsHandler {
    func retrieveProducts(identifiers: [String], completion: ProductsResponse)
}

public extension ProductsHandler {
    func retrieveProducts(identifiers: [String], completion: ProductsResponse) {
        Logging.log("Retrieve products: \(identifiers)")
        let request = SKProductsRequest(productIdentifiers: Set(identifiers))
        Store.sharedInstance.perform(request, completion: completion)
    }
}

private class Store: NSObject, SKProductsRequestDelegate {
    private static let sharedInstance = Store()
    private var requests = [SKProductsRequest: ProductsResponse]()
    
    private func perform(request: SKProductsRequest, completion: ProductsResponse) {
        request.delegate = self
        requests[request] = completion
        request.start()
    }
    
    public func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        Logging.log("Retrieved: \(response.products.count). Invalid \(response.invalidProductIdentifiers)")
        guard let completion = requests.removeValueForKey(request) else {
            return
        }
        
        completion(response.products, response.invalidProductIdentifiers)
    }
}
