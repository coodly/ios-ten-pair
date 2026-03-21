import ComposableArchitecture
import SwiftUI

public struct PlaySummaryView: View {
  private let store: StoreOf<PlaySummary>

  public init(store: StoreOf<PlaySummary>) {
    self.store = store
  }

  public var body: some View {
    HStack(spacing: 0) {
      Image(systemName: "line.horizontal.3")
      Text("x\(store.numbeOfLines.formatted()) ")
        .fixedSize()
      Image(systemName: "square.fill")
      Text("x\(store.numberOfTiles.formatted())")
        .fixedSize()
    }
    .font(Font.body.bold())
    .foregroundColor(store.foregroundColor)
    .onAppear(perform: { store.send(.onAppear) })
  }
}
