import AppAdsFeature
import Autolayout
import Combine
import ComposableArchitecture
import Logging
import MobileAdsClient
import Storyboards
import Themes
import UIKit

public class AdsPresentationViewController: UIViewController, StoryboardLoaded {
    public static var storyboardName: String {
        "AdsPresentation"
    }
    
    public static var instance: Self {
        Storyboards.loadFromStoryboard(from: .module)
    }
    
    public var store: Store<AppAdsState, AppAdsAction>!
    private lazy var viewStore = ViewStore(store)
    
    @IBOutlet private var contentContainer: UIView!
    @IBOutlet private var withoutBannerConstraints: [NSLayoutConstraint]!
    @IBOutlet private var withBannerConstraints: [NSLayoutConstraint]!
    @IBOutlet private var bannerContainer: UIView!
    
    public var contained: UIViewController!
    
    private lazy var adsClient = MobileAdsClient.client
    
    private lazy var disposeBag = Set<AnyCancellable>()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(contained)
        contentContainer.addSubview(contained.view)
        contained.view.frame = view.bounds
        contained.view.pinToSuperviewEdges()
        
        UIView.performWithoutAnimation(contained.view.layoutIfNeeded)
        
        viewStore.publisher.showBannerAd.sink() {
            [weak self]
            
            show in
            
            self?.showBanner(show: show)
        }
        .store(in: &disposeBag)
        viewStore.publisher.presentInterstitial.filter({ $0 }).sink() {
            [weak self]
            
            _ in
            
            self?.presentInterstitial()
        }
        .store(in: &disposeBag)
        
        navigationItem.titleView = contained.navigationItem.titleView
        navigationItem.leftBarButtonItem = contained.navigationItem.leftBarButtonItem
        navigationItem.rightBarButtonItem = contained.navigationItem.rightBarButtonItem
        
        NotificationCenter.default.addObserver(self, selector: #selector(setNeedsStatusBarAppearanceUpdate), name: .themeChanged, object: nil)
        
        let banner = adsClient.bannerView(on: self)
        bannerContainer.addSubview(banner)
        banner.pinToSuperviewEdges()
        
        viewStore.send(.onDidLoad)
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkBannerShow), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        adsClient.reloadBanner(in: view)
    }
    
    @objc fileprivate func checkBannerShow() {
        showBanner(show: viewStore.showBannerAd)
    }
    
    private func showBanner(show: Bool) {
        Log.ads.debug("Show banner: \(show)")
        if show {
            NSLayoutConstraint.deactivate(withoutBannerConstraints)
            NSLayoutConstraint.activate(withBannerConstraints)
        } else {
            NSLayoutConstraint.deactivate(withBannerConstraints)
            NSLayoutConstraint.activate(withoutBannerConstraints)
        }
        
        UIView.animate(withDuration: 0.3, animations: view.layoutIfNeeded)
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        AppTheme.shared.active.statusBar
    }
    
    public override var shouldAutorotate: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .allButUpsideDown
        } else {
            return .portrait
        }
    }
    
    public override func viewWillTransition(to size: CGSize,
                                            with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        coordinator.animate(
            alongsideTransition: { _ in
                self.adsClient.reloadBanner(in: self.view)
            },
            completion: {
                _ in
                
                self.checkBannerShow()
            }
        )
    }
    
    private func presentInterstitial() {
        Log.ads.debug("Try to present interstitial")
        guard adsClient.presentInterstitial(on: self) else {
            return
        }
        
        Log.ads.debug("Interstitial shown")
        viewStore.send(.interstitialShown)
    }
}
