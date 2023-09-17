import ApplicationFeature
import Autolayout
import ComposableArchitecture
import PlayPresentationFeature
import UIKit

public class DesktopLaunchViewController: UIViewController {
    public var store: StoreOf<Application>!
    
    private lazy var playController: PlayViewController = PlayViewController.instance
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        playController.store = store.scope(state: \.playState, action: Application.Action.play)
        
        let navigation = UINavigationController(rootViewController: playController)
        addChild(navigation)
        view.addSubview(navigation.view)
        navigation.view.pinToSuperviewEdges()
    }
}
