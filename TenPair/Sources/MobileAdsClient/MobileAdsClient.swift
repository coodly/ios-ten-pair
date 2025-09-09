import Combine
import Dependencies
import DependenciesMacros
import UIKit

@DependencyClient
public struct MobileAdsClient: Sendable {
  public internal(set) var onLoad: @Sendable () -> Void
  public internal(set) var onUnload: @Sendable () -> Void
  public internal(set) var onBannerView: @Sendable (UIViewController) -> UIView = { _ in UIView() }
  public internal(set) var onPresentInterstitial: @Sendable (UIViewController) -> Bool = { _ in false }
  public internal(set) var onReloadBannerInView: @Sendable (UIView) -> Void
  public internal(set) var onShowBannerPublisher: @Sendable () -> AnyPublisher<Bool, Never> = { Just(false).eraseToAnyPublisher() }
    
  public func load() {
    onLoad()
  }
    
  public func unload() {
    onUnload()
  }
    
  public func bannerView(on root: UIViewController) -> UIView {
    onBannerView(root)
  }
    
  public func presentInterstitial(on root: UIViewController) -> Bool {
    onPresentInterstitial(root)
  }
    
  public func reloadBanner(in view: UIView) {
    onReloadBannerInView(view)
  }
    
  public func showBannerPublisher() -> AnyPublisher<Bool, Never> {
    onShowBannerPublisher()
  }
}

extension MobileAdsClient: TestDependencyKey {
  public static var testValue: MobileAdsClient {
    Self()
  }
}

extension DependencyValues {
  public var mobileAdsClient: MobileAdsClient {
    get { self[MobileAdsClient.self] }
    set { self[MobileAdsClient.self] = newValue }
  }
}

extension MobileAdsClient {
  public static let noAds = MobileAdsClient(
    onLoad: {},
    onUnload: {},
    onBannerView: { _ in fatalError() },
    onPresentInterstitial: {_ in false },
    onReloadBannerInView: { _ in },
    onShowBannerPublisher: { Just(false).eraseToAnyPublisher() }
  )
}
