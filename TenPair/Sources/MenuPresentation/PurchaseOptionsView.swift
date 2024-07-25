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
    WithViewStore(store, observe: { $0 }) {
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
                RowBackground()
                ActivityIndicatorView()
              }
            }
          )
          Button(action: { viewStore.send(.restore) }) {
            Text(L10n.Menu.Option.Restore.purchase)
          }
          .disabled(viewStore.purchaseInProgress)
          .overlay(
            ZStack {
              if viewStore.restoreInProgress {
                RowBackground()
                ActivityIndicatorView()
              }
            }
          )
        }
        if viewStore.purchaseMade {
          Button(action: { viewStore.send(.rateApp) }) {
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
      .animation(.none)
    }
  }
}
