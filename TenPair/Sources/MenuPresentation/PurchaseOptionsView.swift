import ComposableArchitecture
import Localization
import PurchaseFeature
import SwiftUI
import UIComponents

internal struct PurchaseOptionsView: View {
  private let store: StoreOf<Purchase>
    
  internal init(store: StoreOf<Purchase>) {
    self.store = store
  }
    
  var body: some View {
    Group {
      if !store.purchaseMade {
        Button(action: { store.send(.purchase) }) {
          HStack {
            Text(L10n.Menu.Option.Remove.Ads.base)
            if store.productStatus == .loading {
              ActivityIndicatorView()
            } else {
              Text(store.purchasePrice)
            }
          }
        }
        .disabled(store.purchaseInProgress)
        .overlay(
          ZStack {
            if store.purchaseInProgress {
              RowBackground()
              ActivityIndicatorView()
            }
          }
        )
        Button(action: { store.send(.restore) }) {
          Text(L10n.Menu.Option.Restore.purchase)
        }
        .disabled(store.purchaseInProgress)
        .overlay(
          ZStack {
            if store.restoreInProgress {
              RowBackground()
              ActivityIndicatorView()
            }
          }
        )
      }
      if store.purchaseMade {
        Button(action: { store.send(.rateApp) }) {
          Text(L10n.Menu.Option.Rate.app)
        }
      }
      if let message = store.purchaseFailureMessage {
        Text(message)
          .font(Font.body.bold())
          .foregroundColor(.red)
          .multilineTextAlignment(.center)
      }
    }
    .animation(.none)
  }
}
