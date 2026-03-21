import ComposableArchitecture
import MenuFeature
import Localization
import SwiftUI

@ViewAction(for: Restart.self)
internal struct RestartOptionsView: View {
  public let store: StoreOf<Restart>
    
  internal init(store: StoreOf<Restart>) {
    self.store = store
  }
    
  var body: some View {
    Button(action: { send(.tappedRegular) }) {
      Text(L10n.Restart.Screen.Option.regular)
    }
    ForEach(store.randomLines, id: \.self) {
      lines in
      
      Button(action: { send(.tappedRandom(lines)) }) {
        Text(L10n.Restart.Screen.Option.X.lines(lines))
      }
    }
    Button(action: { send(.tappedBack) }) {
      Text(L10n.Restart.Screen.back)
    }
  }
}
