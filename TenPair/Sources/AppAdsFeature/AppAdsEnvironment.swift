import ComposableArchitecture
import Foundation
import MobileAdsClient

public struct AppAdsEnvironment {
    internal let adsClient: MobileAdsClient
    internal let mainQueue: AnySchedulerOf<DispatchQueue>
    public init(
        adsClient: MobileAdsClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.adsClient = adsClient
        self.mainQueue = mainQueue
    }
}
