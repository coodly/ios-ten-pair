import ComposableArchitecture
import Localization
import PurchaseFeature
import SwiftUI

internal struct PurchaseOptionsView: View {
    private let store: Store<PurchaseState, PurchaseAction>
    
    internal init(store: Store<PurchaseState, PurchaseAction>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store) {
            viewStore in
            
            Button(action: {}) {
                HStack {
                    Text(L10n.Menu.Option.Remove.Ads.base)
                }
            }
            Button(action: {}) {
                Text(L10n.Menu.Option.Restore.purchase)
            }
            Button(action: {}) {
                Text(L10n.Menu.Option.Rate.app)
            }
        }
    }
}
