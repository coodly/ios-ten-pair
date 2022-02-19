import ApplicationFeature
import Autolayout
import ComposableArchitecture
import PlayPresentationFeature
import UIKit

public class DesktopLaunchViewController: UIViewController {
    public var store: Store<ApplicationState, ApplicationAction>!
    
    private lazy var playController: PlayViewController = PlayViewController.instance
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigation = UINavigationController(rootViewController: playController)
        addChild(navigation)
        view.addSubview(navigation.view)
        navigation.view.pinToSuperviewEdges()
    }
}
