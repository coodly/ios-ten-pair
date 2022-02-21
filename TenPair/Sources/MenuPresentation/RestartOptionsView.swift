import ComposableArchitecture
import Localization
import RestartFeature
import SwiftUI

internal struct RestartOptionsView: View {
    private let store: Store<RestartState, RestartAction>
    
    internal init(store: Store<RestartState, RestartAction>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store) {
            viewStore in
            
            Button(action: { viewStore.send(.regular) }) {
                Text(L10n.Restart.Screen.Option.regular)
            }
            ForEach(viewStore.randomLines, id: \.self) {
                lines in
                
                Button(action: { viewStore.send(.random(lines)) }) {
                    Text(L10n.Restart.Screen.Option.X.lines(lines))
                }
            }
            Button(action: { viewStore.send(.back) }) {
                Text(L10n.Restart.Screen.back)
            }
        }
    }
}