import ComposableArchitecture
import SwiftUI

@available(iOS 14.0, *)
internal struct MessageEntryView: View {
    internal let store: StoreOf<SendFeedback>
    
    var body: some View {
        WithViewStore(store) {
            viewStore in
            
            HStack(alignment: .top, spacing: 0) {
                ZStack {
                    Text(viewStore.message)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(0)
                        .padding(.all, 8)
                        .padding([.vertical, .leading])
                        .layoutPriority(1)
                    TextEditor(text: viewStore.binding(\.$message))
                        .padding([.vertical, .leading])
                }
                .font(.body)
                VStack {
                    Button(action: { viewStore.send(.postMessage) }) {
                        ZStack {
                            if viewStore.sendingMessage {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Circle()
                                    .padding(2)
                                    .foregroundColor(.white)
                                Image(systemName: "arrow.up.circle.fill")
                                    .resizable()
                            }
                        }
                        .frame(width: 32, height: 32, alignment: .center)
                        .padding()
                    }
                    .foregroundColor(Color.black)
                    .disabled(!viewStore.sumbitEnabled)
                    .opacity(viewStore.sumbitEnabled ? 1 : 0.7)
                }
            }
            .background(
                Color(UIColor.systemFill)
                    .edgesIgnoringSafeArea([Edge.Set.horizontal, Edge.Set.bottom])
            )
        }
    }
}
