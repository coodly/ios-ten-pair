import Localization
import SwiftUI

internal struct FeedbackHeaderView: View {
  var body: some View {
    ZStack {
      Color(red: 0.353, green: 0.784, blue: 0.980)
        .edgesIgnoringSafeArea([Edge.Set.horizontal, Edge.Set.top])
      VStack {
        Text(L10n.Feedback.Greeting.title)
          .frame(maxWidth: .infinity, alignment: .leading)
          .font(.largeTitle)
        Text(L10n.Feedback.Greeting.message)
          .frame(maxWidth: .infinity, alignment: .leading)
          .font(.headline)
      }
      .padding()
      .foregroundColor(Color.white)
    }
  }
}
