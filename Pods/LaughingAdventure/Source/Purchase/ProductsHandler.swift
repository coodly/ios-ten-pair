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

@available(*, deprecated, message: "Use Storefront")
public protocol ProductsHandler {
    func retrieveProducts(_ identifiers: [String], completion: @escaping ProductsResponse)
}

public extension ProductsHandler {
    func retrieveProducts(_ identifiers: [String], completion: @escaping ProductsResponse) {
        Logging.log("Retrieve products: \(identifiers)")
        let request = SKProductsRequest(productIdentifiers: Set(identifiers))
        Store.sharedInstance.perform(request, completion: completion)
    }
}

private class Store: NSObject, SKProductsRequestDelegate {
    fileprivate static let sharedInstance = Store()
    private var requests = [SKProductsRequest: ProductsResponse]()
    
    fileprivate func perform(_ request: SKProductsRequest, completion: @escaping ProductsResponse) {
        request.delegate = self
        requests[request] = completion
        request.start()
    }
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        Logging.log("Retrieved: \(response.products.count). Invalid \(response.invalidProductIdentifiers)")
        guard let completion = requests.removeValue(forKey: request) else {
            return
        }
        
        completion(response.products, response.invalidProductIdentifiers)
    }
}
