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
    .modifier(TheGlass(store: store))
  }
}

struct TheGlass: ViewModifier {
  let store: StoreOf<PlaySummary>
  
  func body(content: Content) -> some View {
    if #available(iOS 26.0, macCatalyst 26.0, *) {
      content
        .frame(minHeight: 44)
        .padding(.horizontal)
        .foregroundStyle(store.foregroundColor)
        .glassEffect(.clear.tint(store.backgroundColor))
    } else {
      content
        .foregroundStyle(store.navigationTint)
    }
  }
}
