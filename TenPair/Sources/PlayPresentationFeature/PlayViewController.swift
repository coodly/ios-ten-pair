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
    
    private lazy var imageConfig = UIImage.SymbolConfiguration(weight: .heavy)
    private lazy var menuImage = UIImage(systemName: "line.horizontal.3.decrease.circle", withConfiguration: imageConfig)
    private lazy var menuButton = UIBarButtonItem(image: menuImage, style: .plain, target: nil, action: nil)
    private lazy var reloadImage = UIImage(systemName: "arrow.2.circlepath", withConfiguration: imageConfig)
    private lazy var reloadButton = UIBarButtonItem(image: reloadImage, style: .plain, target: nil, action: nil)

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = summaryHosting.view
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItem = reloadButton
        menuButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)], for: .normal)
    }
}
