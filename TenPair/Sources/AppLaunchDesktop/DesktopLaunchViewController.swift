import ApplicationFeature
import ComposableArchitecture
import UIKit

public class DesktopLaunchViewController: UIViewController {
    public var store: Store<ApplicationState, ApplicationAction>!
}
