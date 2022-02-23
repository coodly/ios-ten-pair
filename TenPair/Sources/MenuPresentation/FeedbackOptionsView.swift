import ComposableArchitecture
import Localization
import MenuFeature
import SwiftUI

internal struct FeedbackOptionsView: View {
    private let store: Store<MenuState, MenuAction>
    
    internal init(store: Store<MenuState, MenuAction>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store) {
            viewStore in
            
            Button(action: { viewStore.send(.feedback) }) {
                VStack {
                    if viewStore.haveUnreadMessage {
                        Text(L10n.Menu.Option.Message.from)
                    } else {
                        Text(L10n.Menu.Option.Send.message)
                    }
                }
            }
        }
    }
}
