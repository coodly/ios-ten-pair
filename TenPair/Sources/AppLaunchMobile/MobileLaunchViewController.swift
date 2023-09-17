import AdsPresentationFeature
import ApplicationFeature
import Autolayout
import ComposableArchitecture
import PlayPresentationFeature
import Themes
import UIKit

public class MobileLaunchViewController: UIViewController {
    public var store: StoreOf<Application>!
    private lazy var viewStore = ViewStore(store)
    
    private lazy var adsController: AdsPresentationViewController = AdsPresentationViewController.instance
    private lazy var playController: PlayViewController = PlayViewController.instance
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        playController.store = store.scope(state: \.playState, action: Application.Action.play)

        let navigation = PlayNavigationController(rootViewController: playController)
        
        adsController.store = store.scope(state: \.appAdsState, action: Application.Action.appAds)
        adsController.contained = navigation

        addChild(adsController)
        view.addSubview(adsController.view)
        adsController.view.frame = view.bounds
        adsController.view.pinToSuperviewEdges()
        
        UIView.performWithoutAnimation(adsController.view.layoutIfNeeded)
        
        viewStore.send(.onDidLoad)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setNeedsStatusBarAppearanceUpdate), name: .themeChanged, object: nil)
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

}
