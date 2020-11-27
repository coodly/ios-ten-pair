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

import SwiftUI
import Combine

private enum ProductStatus: String {
    case loading
    case loaded
    case failure
}

internal class PurchaseViewModel: ObservableObject {
    
    private lazy var disposeBag = Set<AnyCancellable>()
    @Published fileprivate var productStatus: ProductStatus = .loading
    @Published var product: TenPairProduct?
    
    private let purchase: RevenueCatPurchase
    
    internal init(purchase: RevenueCatPurchase) {
        self.purchase = purchase
        
        loadProduct()
    }
    
    private func loadProduct() {
        let onCompletion: ((Subscribers.Completion<Error>) -> Void) = {
            [weak self]
            
            completion in
            
            switch completion {
            case .failure(_):
                self?.productStatus = .failure
            case .finished:
                self?.productStatus = .loaded
            }
        }
        let process: ((TenPairProduct) -> Void) = {
            [weak self]
            
            product in
            
            self?.product = product
        }
        
        purchase.product().receive(on: DispatchQueue.main)
            .sink(receiveCompletion: onCompletion, receiveValue: process)
            .store(in: &disposeBag)

    }
}

internal struct PurchaseView: View {
    @ObservedObject var viewModel: PurchaseViewModel
    
    var body: some View {
        VStack(spacing: 4) {
            Button(action: {}) {
                HStack(spacing: 0) {
                    Text(L10n.Menu.Option.Remove.Ads.base)
                    if viewModel.productStatus == .loading {
                        ActivityIndicatorView()
                    } else {
                        Text(viewModel.product?.localizedPrice ?? "-")
                    }
                }
            }
            Button(action: {}) {
                Text(L10n.Menu.Option.Restore.purchase)
            }
        }
    }
}
