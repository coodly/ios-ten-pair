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
        WithViewStore(store, observe: { $0 }) {
            viewStore in

            Button(action: { viewStore.send(.resume) }) {
                Text(L10n.Menu.Option.resume)
            }
            Button(action: { viewStore.send(.restartTapped) }) {
                Text(L10n.Menu.Option.restart)
            }
            Button(action: { viewStore.send(.theme) }) {
                Text(L10n.Menu.Option.Theme.base(viewStore.activeThemeName))
            }
            IfLetStore(
                store.scope(state: \.purchaseState, action: MenuFeature.Menu.Action.purchase),
                then: PurchaseOptionsView.init(store:)
            )
            if viewStore.feedbackEnabled {
                FeedbackOptionsView(store: store)
            }
        }
    }
}
