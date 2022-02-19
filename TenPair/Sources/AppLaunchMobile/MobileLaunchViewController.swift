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

        adsController.store = store.scope(state: \.appAdsState, action: ApplicationAction.appAds)
        adsController.contained = playController        

        let navigation = PlayNavigationController(rootViewController: adsController)
        addChild(navigation)
        view.addSubview(navigation.view)
        navigation.view.pinToSuperviewEdges()
    }
}
