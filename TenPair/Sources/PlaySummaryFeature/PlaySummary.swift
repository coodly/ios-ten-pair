import ComposableArchitecture
import Themes
import SwiftUI

@Reducer
public struct PlaySummary {
  public struct State: Equatable {
    internal var numbeOfLines = 123
    internal var numberOfTiles = 43
        
    internal var foregroundColor = Color.primary
        
    public init() {
            
    }
  }
    
  public enum Action: Sendable {
    case onAppear
        
    case update(lines: Int, tiles: Int)
        
    case updateForeground(Color)
  }
    
  public init() {
        
  }
    
  @Dependency(\.mainQueue) var mainQueue
    
  public var body: some ReducerOf<Self> {
    Reduce {
      state, action in
            
      switch action {
      case .onAppear:
        state.foregroundColor = Color(AppTheme.shared.active.navigationTint)
        return Effect.publisher({ NotificationCenter.default.publisher(for: .themeChanged) })
          .map({ _ in AppTheme.shared.active.navigationTint })
          .map(Color.init)
          .map(Action.updateForeground)
                
      case .updateForeground(let color):
        state.foregroundColor = color
        return .none
                
      case .update(let lines, let tiles):
        state.numbeOfLines = lines
        state.numberOfTiles = tiles
        return .none
      }
    }
  }
}
