import MobileAdsClient

public struct AppAdsEnvironment {
    internal let adsClient: MobileAdsClient
    public init(adsClient: MobileAdsClient) {
        self.adsClient = adsClient
    }
}
