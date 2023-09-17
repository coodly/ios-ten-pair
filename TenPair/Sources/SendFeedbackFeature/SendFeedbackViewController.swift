import Autolayout
import ComposableArchitecture
import Storyboards
import SwiftUI
import UIKit

@available(iOS 14.0, *)
public class SendFeedbackViewController: UIViewController, StoryboardLoaded {
    public static var storyboardName: String {
        "SendFeedback"
    }
    
    public static var instance: Self {
        Storyboards.loadFromStoryboard(from: .module)
    }
    
    public var store: StoreOf<SendFeedback>!
    private lazy var viewStore = ViewStore(store)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let sendView = SendFeedbackView(store: store)
        let hosting = UIHostingController(rootView: sendView)
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.pinToSuperviewEdges()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewStore.send(.onAppear)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewStore.send(.onDisappear)
    }
}
