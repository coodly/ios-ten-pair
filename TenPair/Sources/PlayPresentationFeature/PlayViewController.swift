import ComposableArchitecture
import PlayFeature
import PlaySummaryFeature
import Storyboards
import SwiftUI
import UIKit

public class PlayViewController: UIViewController, StoryboardLoaded {
    public static var storyboardName: String {
        "Play"
    }
    
    public static var instance: Self {
        Storyboards.loadFromStoryboard(from: .module)
    }
    
    public var store: Store<PlayState, PlayAction>!
    
    private lazy var summaryStore = store.scope(state: \.playSummaryState, action: PlayAction.playSummary)
    private lazy var summaryView = PlaySummaryView(store: summaryStore)
    private lazy var summaryHosting = UIHostingController(rootView: summaryView)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if parent is UINavigationController {
            navigationItem.titleView = summaryHosting.view
        } else {
            parent?.navigationItem.titleView = summaryHosting.view
        }
    }
}
