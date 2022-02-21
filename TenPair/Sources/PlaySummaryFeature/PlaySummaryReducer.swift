import ComposableArchitecture
import Themes
import SwiftUI

public let playSummaryReducer = Reducer<PlaySummaryState, PlaySummaryAction, PlaySummaryEnvironment>.combine(
    reducer
)

private let reducer = Reducer<PlaySummaryState, PlaySummaryAction, PlaySummaryEnvironment>() {
    state, action, env in
    
    switch action {
    case .onAppear:
        state.foregroundColor = Color(AppTheme.shared.active.navigationTint)
        return Effect(NotificationCenter.default.publisher(for: .themeChanged))
            .map({ _ in AppTheme.shared.active.navigationTint })
            .map(Color.init)
            .map(PlaySummaryAction.updateForeground)
            .receive(on: env.mainQueue)
            .eraseToEffect()
        
    case .updateForeground(let color):
        state.foregroundColor = color
        return .none
        
    case .update(let lines, let tiles):
        state.numbeOfLines = lines
        state.numberOfTiles = tiles
        return .none
    }
}
