import ComposableArchitecture
import Localization
import MenuFeature
import SwiftUI
import Themes

@ViewAction(for: MenuFeature.Menu.self)
internal struct RegularOptionsView: View {
  public let store: StoreOf<MenuFeature.Menu>

  internal init(store: StoreOf<MenuFeature.Menu>) {
    self.store = store
  }

  var body: some View {
    Button(action: { send(.tappedResume) }) {
      Text(L10n.Menu.Option.resume)
    }
    Button(action: { send(.tappedRestart) }) {
      Text(L10n.Menu.Option.restart)
    }
    Button(action: { send(.tappedTheme) }) {
      Text(L10n.Menu.Option.Theme.base(store.activeThemeName))
    }
    if let store = store.scope(state: \.purchaseState, action: \.purchase) {
      PurchaseOptionsView(store: store)
    }
    if store.feedbackEnabled {
      FeedbackOptionsView(store: store)
    }
  }
}
