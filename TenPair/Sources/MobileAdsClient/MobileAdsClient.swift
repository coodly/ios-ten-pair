import Combine
import UIKit

public struct MobileAdsClient {
    private let onBannerView: ((UIViewController) -> UIView)
    private let onReloadBannerInView: ((UIView) -> Void)
    private let onShowBannerPublisher: (() -> AnyPublisher<Bool, Never>)
    
    public init(
        onBannerView: @escaping ((UIViewController) -> UIView),
        onReloadBannerInView: @escaping ((UIView) -> Void),
        onShowBannerPublisher: @escaping (() -> AnyPublisher<Bool, Never>)
    ) {
        self.onBannerView = onBannerView
        self.onReloadBannerInView = onReloadBannerInView
        self.onShowBannerPublisher = onShowBannerPublisher
    }
    
    public func bannerView(on root: UIViewController) -> UIView {
        onBannerView(root)
    }
    
    public func reloadBanner(in view: UIView) {
        onReloadBannerInView(view)
    }
    
    public func showBannerPublisher() -> AnyPublisher<Bool, Never> {
        onShowBannerPublisher()
    }
}

extension MobileAdsClient {
    public static var client: Self = .noAds
}

extension MobileAdsClient {
    public static let noAds = MobileAdsClient(
        onBannerView: { _ in fatalError() },
        onReloadBannerInView: { _ in },
        onShowBannerPublisher: { Just(false).eraseToAnyPublisher() }
    )
}
