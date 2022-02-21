import Themes
import UIKit

public class PlayNavigationController: UINavigationController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setNeedsStatusBarAppearanceUpdate), name: .themeChanged, object: nil)
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        AppTheme.shared.active.statusBar
    }
    
    public override var shouldAutorotate: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .allButUpsideDown
        } else {
            return .portrait
        }
    }
}
