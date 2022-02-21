import ComposableArchitecture
import SwiftUI

extension NumberFormatter {
    fileprivate static let number: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.usesGroupingSeparator = true
        return formatter
    }()
}

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
                Text("x\(String(describing: viewStore.numbeOfLines)) ")
                    .fixedSize()
                Image(systemName: "square.fill")
                Text("x\(String(describing: viewStore.numberOfTiles))")
                    .fixedSize()
            }
            .font(Font.body.bold())
            .foregroundColor(viewStore.foregroundColor)
            .onAppear(perform: { viewStore.send(.onAppear) })
        }
    }
}
