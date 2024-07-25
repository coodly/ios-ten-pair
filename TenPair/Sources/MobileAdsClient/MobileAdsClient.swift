import Combine
import Dependencies
import UIKit
import XCTestDynamicOverlay

public struct MobileAdsClient {
  private let onLoad: (() -> Void)
  private let onUnload: (() -> Void)
  private let onBannerView: ((UIViewController) -> UIView)
  private let onPresentInterstitial: ((UIViewController) -> Bool)
  private let onReloadBannerInView: ((UIView) -> Void)
  private let onShowBannerPublisher: (() -> AnyPublisher<Bool, Never>)
    
  public init(
    onLoad: @escaping (() -> Void),
    onUnload: @escaping (() -> Void),
    onBannerView: @escaping ((UIViewController) -> UIView),
    onPresentInterstitial: @escaping ((UIViewController) -> Bool),
    onReloadBannerInView: @escaping ((UIView) -> Void),
    onShowBannerPublisher: @escaping (() -> AnyPublisher<Bool, Never>)
  ) {
    self.onLoad = onLoad
    self.onUnload = onUnload
    self.onBannerView = onBannerView
    self.onPresentInterstitial = onPresentInterstitial
    self.onReloadBannerInView = onReloadBannerInView
    self.onShowBannerPublisher = onShowBannerPublisher
  }
    
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
    MobileAdsClient(
      onLoad: unimplemented("\(Self.self).onLoad"),
      onUnload: unimplemented("\(Self.self).onUnload"),
      onBannerView: unimplemented("\(Self.self).onBannerView"),
      onPresentInterstitial: unimplemented("\(Self.self).onPresentInterstitial"),
      onReloadBannerInView: unimplemented("\(Self.self).onReloadBannerInView"),
      onShowBannerPublisher: unimplemented("\(Self.self).onShowBannerPublisher")
    )
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
