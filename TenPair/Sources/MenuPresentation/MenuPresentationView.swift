import ComposableArchitecture
import MenuFeature
import SwiftUI

internal struct MenuPresentationView: View {
  private let store: StoreOf<MenuFeature.Menu>
    
  internal init(store: StoreOf<MenuFeature.Menu>) {
    self.store = store
  }
    
  var body: some View {
    ZStack {
      MenuBackground()
        .edgesIgnoringSafeArea(.all)
        .onTapGesture(perform: { store.send(.resume) })
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
