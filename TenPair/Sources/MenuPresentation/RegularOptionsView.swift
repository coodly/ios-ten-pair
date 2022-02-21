import ComposableArchitecture
import Localization
import MenuFeature
import SwiftUI
import Themes

internal struct RegularOptionsView: View {
    private let store: Store<MenuState, MenuAction>
    
    internal init(store: Store<MenuState, MenuAction>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store) {
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
        }
    }
}
