import ComposableArchitecture
import Localization
import PurchaseFeature
import SwiftUI
import UIComponents

internal struct PurchaseOptionsView: View {
    private let store: Store<PurchaseState, PurchaseAction>
    
    internal init(store: Store<PurchaseState, PurchaseAction>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(store) {
            viewStore in
            
            Group {
                if !viewStore.purchaseMade {
                    Button(action: {}) {
                        HStack {
                            Text(L10n.Menu.Option.Remove.Ads.base)
                            if viewStore.productStatus == .loading {
                                ActivityIndicatorView()
                            } else {
                                Text(viewStore.purchasePrice)
                            }
                        }
                    }
                    Button(action: {}) {
                        Text(L10n.Menu.Option.Restore.purchase)
                    }
                }
                if viewStore.purchaseMade {
                    Button(action: {}) {
                        Text(L10n.Menu.Option.Rate.app)
                    }
                }
            }
            .onAppear(perform: { viewStore.send(.onAppear) })
            .onDisappear(perform: { viewStore.send(.onDisappear) })
        }
    }
}
