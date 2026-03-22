import ComposableArchitecture
import MenuFeature
import SwiftUI

@ViewAction(for: MenuFeature.Menu.self)
internal struct MenuPresentationView: View {
  public let store: StoreOf<MenuFeature.Menu>

  internal init(store: StoreOf<MenuFeature.Menu>) {
    self.store = store
  }

  var body: some View {
    ZStack {
      MenuBackground()
        .edgesIgnoringSafeArea(.all)
        .onTapGesture(perform: { send(.tappedResume) })
      VStack(spacing: 4) {
        if let store = store.scope(state: \.restartState, action: \.restart) {
          RestartOptionsView(store: store)
        } else {
          RegularOptionsView(store: store)
        }
      }
      .frame(width: 280)
      .buttonStyle(MenuButtonStyle())
    }
  }
}
