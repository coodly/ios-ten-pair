import ComposableArchitecture
import PlayFeature
import SwiftUI

struct HintTrayView: View {
  let store: StoreOf<ButtonTray>
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      Image(systemName: "lightbulb.fill")
        .font(.headline.weight(.heavy))
        .frame(width: 44, height: 44)
    }
    .padding(.leading, 4)
    .modifier(HintTrayModifier(store: store))
    .padding(.bottom)
    .foregroundStyle(store.foregroundColor)
  }
}

struct HintTrayModifier: ViewModifier {
  let store: StoreOf<ButtonTray>
  let rectangle = UnevenRoundedRectangle(
    topLeadingRadius: 0,
    bottomLeadingRadius: 0,
    bottomTrailingRadius: 22,
    topTrailingRadius: 22,
    style: .continuous
  )
  
  func body(content: Content) -> some View {
    if #available(iOS 26.0, *) {
      content
        .glassEffect(in: rectangle)
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
