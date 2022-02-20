import AdsPresentationFeature
import ApplicationFeature
import Autolayout
import ComposableArchitecture
import PlayPresentationFeature
import UIKit

public class MobileLaunchViewController: UIViewController {
    public var store: Store<ApplicationState, ApplicationAction>!
    
    private lazy var adsController: AdsPresentationViewController = AdsPresentationViewController.instance
    private lazy var playController: PlayViewController = PlayViewController.instance
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        playController.store = store.scope(state: \.playState, action: ApplicationAction.play)

        let navigation = PlayNavigationController(rootViewController: playController)
        
        adsController.store = store.scope(state: \.appAdsState, action: ApplicationAction.appAds)
        adsController.contained = navigation

        addChild(adsController)
        view.addSubview(adsController.view)
        adsController.view.frame = view.bounds
        adsController.view.pinToSuperviewEdges()
        
        UIView.performWithoutAnimation(adsController.view.layoutIfNeeded)
    }
}
