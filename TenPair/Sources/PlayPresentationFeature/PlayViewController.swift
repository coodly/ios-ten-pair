import UIKit
import Storyboards

public class PlayViewController: UIViewController, StoryboardLoaded {
    public static var storyboardName: String {
        "Play"
    }
    
    public static var instance: Self {
        Storyboards.loadFromStoryboard(from: .module)
    }
}
