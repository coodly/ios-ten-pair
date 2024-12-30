import Autolayout
import Combine
import ComposableArchitecture
import MenuFeature
import SendFeedbackFeature
import Storyboards
import SwiftUI

public class MenuPresentationViewController: UIViewController, StoryboardLoaded {
  public static var storyboardName: String {
    "MenuPresentation"
  }
    
  public static var instance: Self {
    Storyboards.loadFromStoryboard(from: .module)
  }
    
  public var store: StoreOf<MenuFeature.Menu>!
  private lazy var viewStore = ViewStore(store, observe: { $0 })
  private lazy var menuView = MenuPresentationView(store: store)
  private lazy var disposeBag = Set<AnyCancellable>()
    
  public override func viewDidLoad() {
    super.viewDidLoad()
        
    let hosting = UIHostingController(rootView: menuView)
    addChild(hosting)
        
    view.addSubview(hosting.view)
    hosting.view.pinToSuperviewEdges()
    hosting.view.backgroundColor = .clear
    view.backgroundColor = .clear
        
    store.scope(state: \.sendFeedbackState, action: \.sendFeedback).ifLet(
      then: {
        [weak self]
                
        store in
                
        self?.presentFeedback(store: store)
      }
    )
    .store(in: &disposeBag)
  }
    
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
        
    viewStore.send(.willAppear)
  }
    
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
        
    viewStore.send(.willDisappear)
  }
    
  private func presentFeedback(store: StoreOf<SendFeedback>) {
    guard #available(iOS 14.0, *) else {
      return
    }
    
    let controller = SendFeedbackViewController.instance
    controller.store = store
    let navigation = UINavigationController(rootViewController: controller)
    navigation.modalPresentationStyle = .formSheet
    controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissFeedback))
        
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor(red: 0.353, green: 0.784, blue: 0.980, alpha: 1)
    appearance.buttonAppearance = UIBarButtonItemAppearance(style: .plain)
    appearance.buttonAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    navigation.navigationBar.standardAppearance = appearance
    navigation.navigationBar.scrollEdgeAppearance = appearance
    navigation.navigationBar.tintColor = .white

    present(navigation, animated: true)
  }
    
  @objc fileprivate func dismissFeedback() {
    dismiss(animated: true)
  }
}
