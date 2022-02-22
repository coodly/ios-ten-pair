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
                    Button(action: { viewStore.send(.purchase) }) {
                        HStack {
                            Text(L10n.Menu.Option.Remove.Ads.base)
                            if viewStore.productStatus == .loading {
                                ActivityIndicatorView()
                            } else {
                                Text(viewStore.purchasePrice)
                            }
                        }
                    }
                    .disabled(viewStore.purchaseInProgress)
                    .overlay(
                        ZStack {
                            if viewStore.purchaseInProgress {
                                MenuBackground()
                                ActivityIndicatorView()
                            }
                        }
                    )
                    Button(action: {}) {
                        Text(L10n.Menu.Option.Restore.purchase)
                    }
                }
                if viewStore.purchaseMade {
                    Button(action: {}) {
                        Text(L10n.Menu.Option.Rate.app)
                    }
                }
                if let message = viewStore.purchaseFailureMessage {
                    Text(message)
                        .font(Font.body.bold())
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}
