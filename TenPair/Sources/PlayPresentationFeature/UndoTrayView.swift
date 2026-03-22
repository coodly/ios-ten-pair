import ComposableArchitecture
import PlayFeature
import SwiftUI

struct UndoTrayView: View {
  let store: StoreOf<ButtonTray>
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: "arrow.counterclockwise")
        .font(.headline.weight(.heavy))
        .frame(width: 44, height: 44)
    }
    .padding(.trailing, 4)
    .modifier(UndoTrayModifier(store: store))
    .padding(.bottom)
    .foregroundStyle(store.foregroundColor)
  }
}

struct UndoTrayModifier: ViewModifier {
  let store: StoreOf<ButtonTray>
  let rectangle = UnevenRoundedRectangle(
    topLeadingRadius: 22,
    bottomLeadingRadius: 22,
    bottomTrailingRadius: 0,
    topTrailingRadius: 0,
    style: .continuous
  )

  func body(content: Content) -> some View {
    if #available(iOS 26.0, *) {
      content
        .glassEffect(.clear.tint(store.backgroundColor), in: rectangle)
    } else {
      content
        .foregroundStyle(store.foregroundColor)
        .background(
          content: {
            rectangle
              .foregroundStyle(store.backgroundColor)
          }
        )
        .overlay(
          rectangle
            .stroke(store.foregroundColor, lineWidth: 1)
        )
    }
  }
}
