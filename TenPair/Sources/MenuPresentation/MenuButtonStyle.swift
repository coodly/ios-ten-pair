import SwiftUI
import UIKit

internal struct MenuButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(Font(UIFont(name: "Copperplate Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)))
      .foregroundColor(.white)
      .frame(minWidth: 44, maxWidth: .infinity, minHeight: 50, alignment: .center)
      .multilineTextAlignment(.center)
      .lineLimit(nil)
      .background(RowBackground())
      .opacity(configuration.isPressed ? 0.7 : 1.0)
  }
}
