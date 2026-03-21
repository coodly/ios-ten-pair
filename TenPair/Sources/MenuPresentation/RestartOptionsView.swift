import ComposableArchitecture
import Localization
import RestartFeature
import SwiftUI

internal struct RestartOptionsView: View {
  private let store: StoreOf<Restart>
    
  internal init(store: StoreOf<Restart>) {
    self.store = store
  }
    
  var body: some View {
    Button(action: { store.send(.regular) }) {
      Text(L10n.Restart.Screen.Option.regular)
    }
    ForEach(store.randomLines, id: \.self) {
      lines in
      
      Button(action: { store.send(.random(lines)) }) {
        Text(L10n.Restart.Screen.Option.X.lines(lines))
      }
    }
    Button(action: { store.send(.back) }) {
      Text(L10n.Restart.Screen.back)
    }
  }
}
