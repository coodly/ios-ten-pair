import AppAdsFeature
import Autolayout
import Combine
import ComposableArchitecture
import Storyboards
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
    @IBOutlet private var bannerHeight: NSLayoutConstraint!

    public var contained: UIViewController!
    
    private lazy var disposeBag = Set<AnyCancellable>()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(contained)
        contentContainer.addSubview(contained.view)
        contained.view.pinToSuperviewEdges()
        
        viewStore.publisher.showBannerAd.sink() {
            [weak self]
            
            show in
            
            self?.showBanne(show: show)
        }
        .store(in: &disposeBag)
        
        navigationItem.titleView = contained.navigationItem.titleView
        navigationItem.leftBarButtonItem = contained.navigationItem.leftBarButtonItem
        navigationItem.rightBarButtonItem = contained.navigationItem.rightBarButtonItem
    }
    
    private func showBanne(show: Bool) {
        if show {
            NSLayoutConstraint.deactivate(withoutBannerConstraints)
            NSLayoutConstraint.activate(withBannerConstraints)
        } else {
            NSLayoutConstraint.deactivate(withBannerConstraints)
            NSLayoutConstraint.activate(withoutBannerConstraints)
        }
        
        UIView.animate(withDuration: 0.3, animations: view.layoutIfNeeded)
    }
}
