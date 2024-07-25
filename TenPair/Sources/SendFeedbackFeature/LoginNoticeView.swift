import Localization
import SwiftUI

internal struct LoginNoticeView: View {
  var body: some View {
    Text(L10n.Feedback.Login.notice)
      .font(.body)
      .multilineTextAlignment(.center)
      .frame(maxWidth: .infinity, alignment: .center)
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 10)
          .foregroundColor(Color(UIColor.systemBackground))
      )
      .padding(.horizontal)
  }
}

