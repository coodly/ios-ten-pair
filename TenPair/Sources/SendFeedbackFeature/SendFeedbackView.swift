import ComposableArchitecture
import SwiftUI

@available(iOS 14.0, *)
internal struct SendFeedbackView: View {
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
                        
            WithViewStore(store, observe: { $0 }) {
              viewStore in
                            
              if viewStore.isLoggedIn {
                ForEach(viewStore.messages) {
                  message in
                                    
                  MessageBubbleView(message: message)
                }
                .onChange(of: viewStore.lastMessageId) {
                  target in
                                    
                  proxy.scrollTo(target, anchor: .bottom)
                }
              } else {
                LoginNoticeView()
              }
            }
          }
        }
      }
      WithViewStore(store, observe: { $0 }) {
        viewStore in
                
        if viewStore.state.isLoggedIn {
          MessageEntryView(store: store)
        }
      }
    }
    .lineLimit(nil)
    .background(Color(UIColor.secondarySystemBackground))
  }
}
