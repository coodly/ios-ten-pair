import CloudMessagesClient
import ComposableArchitecture
import Localization
import MenuFeature
import SwiftUI

@ViewAction(for: MenuFeature.Menu.self)
internal struct FeedbackOptionsView: View {
  @Shared(.hasUnreadMessages) var hasUnreadMessages
  public let store: StoreOf<MenuFeature.Menu>

  internal init(store: StoreOf<MenuFeature.Menu>) {
    self.store = store
  }

  var body: some View {
    Button(action: { send(.tappedFeedback) }) {
      VStack {
        if hasUnreadMessages {
          Text(L10n.Menu.Option.Message.from)
        } else {
          Text(L10n.Menu.Option.Send.message)
        }
      }
    }
  }
}
