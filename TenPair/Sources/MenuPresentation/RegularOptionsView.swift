import ComposableArchitecture
import Localization
import MenuFeature
import SwiftUI
import Themes

internal struct RegularOptionsView: View {
  private let store: StoreOf<MenuFeature.Menu>

  internal init(store: StoreOf<MenuFeature.Menu>) {
    self.store = store
  }

  var body: some View {
    Button(action: { store.send(.resume) }) {
      Text(L10n.Menu.Option.resume)
    }
    Button(action: { store.send(.restartTapped) }) {
      Text(L10n.Menu.Option.restart)
    }
    Button(action: { store.send(.theme) }) {
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
