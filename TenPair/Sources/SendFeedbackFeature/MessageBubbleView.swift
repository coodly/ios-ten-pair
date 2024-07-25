import CloudMessagesClient
import SwiftUI

internal struct MessageBubbleView: View {
  private let message: Message
  public init(message: Message) {
    self.message = message
  }

  internal var body: some View {
    HStack {
      if message.sentFromApp {
        Spacer(minLength: 20)
      }
      VStack(alignment: message.sentFromApp ? .trailing: .leading) {
        let from = message.sentBy
        if from.count > 0 {
          Text(from)
            .font(Font.subheadline.bold())
            .foregroundColor(Color(UIColor.secondaryLabel))
        }
        Text(message.content)
          .font(.body)
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 10)
          .foregroundColor(Color(UIColor.systemBackground))
      )
      if !message.sentFromApp {
        Spacer(minLength: 20)
      }
    }
    .padding(.horizontal)
  }
}

