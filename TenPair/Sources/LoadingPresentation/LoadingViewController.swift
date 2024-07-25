import Storyboards
import UIComponents
import UIKit

private let Width = CGFloat(150)

public class LoadingViewController: UIViewController, StoryboardLoaded {
  public static var storyboardName: String {
    "Loading"
  }
    
  public static var instance: Self {
    Storyboards.loadFromStoryboard(from: .module)
  }
    
  private lazy var spinner = SpinnerView(frame: CGRect(x: 0, y: 0, width: Width, height: Width))
    
  public override func viewDidLoad() {
    super.viewDidLoad()
        
    view.addSubview(spinner)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    spinner.widthAnchor.constraint(equalToConstant: Width).isActive = true
    spinner.heightAnchor.constraint(equalToConstant: Width).isActive = true
        
    spinner.backgroundColor = .clear
  }
    
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
        
    spinner.animate()
  }
    
  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
        
    spinner.stop()
  }
}
