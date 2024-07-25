import ComposableArchitecture
import Localization
import MenuFeature
import SwiftUI

internal struct FeedbackOptionsView: View {
  private let store: StoreOf<MenuFeature.Menu>
    
  internal init(store: StoreOf<MenuFeature.Menu>) {
    self.store = store
  }
    
  var body: some View {
    WithViewStore(store, observe: { $0 }) {
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
