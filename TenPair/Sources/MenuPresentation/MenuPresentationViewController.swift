import Autolayout
import ComposableArchitecture
import MenuFeature
import Storyboards
import SwiftUI

public class MenuPresentationViewController: UIViewController, StoryboardLoaded {
    public static var storyboardName: String {
        "MenuPresentation"
    }
    
    public static var instance: Self {
        Storyboards.loadFromStoryboard(from: .module)
    }
    
    public var store: Store<MenuState, MenuAction>!
    private lazy var viewStore = ViewStore(store)
    private lazy var menuView = MenuPresentationView(store: store)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let hosting = UIHostingController(rootView: menuView)
        addChild(hosting)
        
        view.addSubview(hosting.view)
        hosting.view.pinToSuperviewEdges()
        hosting.view.backgroundColor = .clear
        view.backgroundColor = .clear
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewStore.send(.willAppear)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewStore.send(.willDisappear)
    }
}
