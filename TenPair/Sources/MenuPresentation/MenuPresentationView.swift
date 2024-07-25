import ComposableArchitecture
import MenuFeature
import SwiftUI

internal struct MenuPresentationView: View {
  private let store: StoreOf<MenuFeature.Menu>
    
  internal init(store: StoreOf<MenuFeature.Menu>) {
    self.store = store
  }
    
  var body: some View {
    WithViewStore(store, observe: { $0 }) {
      viewStore in
            
      ZStack {
        MenuBackground()
          .edgesIgnoringSafeArea(.all)
          .onTapGesture(perform: { viewStore.send(.resume) })
        VStack(spacing: 4) {
          IfLetStore(
            store.scope(state: \.restartState, action: MenuFeature.Menu.Action.restart),
            then: RestartOptionsView.init(store:),
            else: {
              RegularOptionsView(store: store)
            }
          )
        }
        .frame(width: 280)
        .buttonStyle(MenuButtonStyle())
      }
    }
  }
}
