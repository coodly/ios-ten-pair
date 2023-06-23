import ComposableArchitecture
import Foundation
import PurchaseClient
import RateAppClient

public struct PurchaseEnvironment {
    internal let mainQueue: AnySchedulerOf<DispatchQueue>
    internal let purchaseClient: PurchaseClient
    internal let rateAppClient: RateAppClient
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        purchaseClient: PurchaseClient,
        rateAppClient: RateAppClient
    ) {
        self.mainQueue = mainQueue
        self.purchaseClient = purchaseClient
        self.rateAppClient = rateAppClient
    }
}
