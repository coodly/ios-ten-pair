import ApplicationFeature
import ComposableArchitecture
import UIKit

public class MobileLaunchViewController: UIViewController {
    public var store: Store<ApplicationState, ApplicationAction>!
}
