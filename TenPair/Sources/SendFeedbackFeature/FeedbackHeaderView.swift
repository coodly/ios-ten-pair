import Localization
import SwiftUI

internal struct FeedbackHeaderView: View {
    var body: some View {
        ZStack {
            Color.black
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
            .foregroundColor(Color.primary)
        }
    }
}
