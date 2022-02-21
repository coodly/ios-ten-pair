import ComposableArchitecture
import MenuFeature
import SwiftUI

internal struct MenuPresentationView: View {
    private let store: Store<MenuState, MenuAction>
    
    internal init(store: Store<MenuState, MenuAction>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store) {
            viewStore in
            
            ZStack {
                MenuBackground()
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture(perform: { viewStore.send(.resume) })
                VStack(spacing: 4) {
                    IfLetStore(
                        store.scope(state: \.restartState, action: MenuAction.restart),
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
