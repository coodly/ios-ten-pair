import ComposableArchitecture
import SwiftUI

public struct PlaySummaryView: View {
    private let store: Store<PlaySummaryState, PlaySummaryAction>
    
    public init(store: Store<PlaySummaryState, PlaySummaryAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) {
            viewStore in
            
            HStack(spacing: 0) {
                Image(systemName: "line.horizontal.3")
                Text("x\(viewStore.numbeOfLines) ")
                Image(systemName: "square.fill")
                Text("x\(viewStore.numberOfTiles)")
            }
            .font(Font.body.bold())
        }
    }
}
