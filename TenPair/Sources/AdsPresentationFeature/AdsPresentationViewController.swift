import Autolayout
import Storyboards
import UIKit

public class AdsPresentationViewController: UIViewController, StoryboardLoaded {
    public static var storyboardName: String {
        "AdsPresentation"
    }
    
    public static var instance: Self {
        Storyboards.loadFromStoryboard(from: .module)
    }
    
    @IBOutlet private var contentContainer: UIView!

    public var contained: UIViewController!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(contained)
        contentContainer.addSubview(contained.view)
        contained.view.pinToSuperviewEdges()
    }
}
