import ComposableArchitecture
import SwiftUI

internal struct SendFeedbackView: View {
    private let store: Store<SendFeedbackState, SendFeedbackAction>
    
    internal init(store: Store<SendFeedbackState, SendFeedbackAction>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader {
                    proxy in
                    
                    VStack {
                        FeedbackHeaderView()
                        
                        WithViewStore(store) {
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
            WithViewStore(store) {
                viewStore in
                
                if viewStore.state.isLoggedIn {
                    MessageEntryView(store: store)
                }
            }
        }
        .lineLimit(nil)
        .background(Color.black)
    }
}
