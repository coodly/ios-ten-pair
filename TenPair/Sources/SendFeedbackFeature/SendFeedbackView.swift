import ComposableArchitecture
import CloudMessagesClient
import SwiftUI

@available(iOS 14.0, *)
internal struct SendFeedbackView: View {
  @Shared(.messages) var messages
  
  private let store: StoreOf<SendFeedback>
    
  internal init(store: StoreOf<SendFeedback>) {
    self.store = store
  }
    
  var body: some View {
    VStack {
      ScrollView {
        ScrollViewReader {
          proxy in
                    
          VStack {
            FeedbackHeaderView()
                        
            if store.isLoggedIn {
              ForEach(messages) {
                message in
                
                MessageBubbleView(message: message)
              }
              .onChange(of: messages.last?.id) {
                oldValue, newValue in
                
                proxy.scrollTo(newValue, anchor: .bottom)
              }
            } else {
              LoginNoticeView()
            }
          }
        }
      }
      if store.isLoggedIn {
        MessageEntryView(store: store)
      }
    }
    .lineLimit(nil)
    .background(Color(UIColor.secondarySystemBackground))
  }
}
