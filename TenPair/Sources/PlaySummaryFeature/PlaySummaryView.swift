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
    .modifier(TheGlass())
  }
}

struct TheGlass: ViewModifier {
  func body(content: Content) -> some View {
    if #available(iOS 26.0, macCatalyst 26.0, *) {
      content
        .frame(minHeight: 44)
        .padding(.horizontal)
        .glassEffect()
    } else {
      content
    }
  }
}
