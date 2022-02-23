/*
* Copyright 2021 Coodly LLC
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
import Foundation

public enum ShowAdsStatus: String {
    case unknown
    case removed
    case show
}

public protocol TenPairProduct {
    var localizedPrice: String { get }
    var identifier: String { get }
}

public struct RemoveAds {
    public let platformHasAds: Bool
    public let adsStatus: (() -> AnyPublisher<ShowAdsStatus, Never>)
    public let load: (() -> Void)
    public let product: (() -> AnyPublisher<TenPairProduct, Error>)
    public let purchase: ((TenPairProduct) -> AnyPublisher<Bool, Error>)
    public let restore: (() -> AnyPublisher<Bool, Error>)

    public init(platformHasAds: Bool,
                adsStatus: @escaping (() -> AnyPublisher<ShowAdsStatus, Never>),
                load: @escaping (() -> Void),
                product: @escaping (() -> AnyPublisher<TenPairProduct, Error>),
                purchase: @escaping ((TenPairProduct) -> AnyPublisher<Bool, Error>),
                restore: @escaping (() -> AnyPublisher<Bool, Error>)) {
        self.platformHasAds = platformHasAds
        self.adsStatus = adsStatus
        self.load = load
        self.product = product
        self.purchase = purchase
        self.restore = restore
    }
}
