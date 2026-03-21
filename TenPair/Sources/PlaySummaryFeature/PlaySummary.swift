import ComposableArchitecture
import Themes
import SwiftUI

@Reducer
public struct PlaySummary {
  @ObservableState
  public struct State: Equatable {
    internal var numbeOfLines = 123
    internal var numberOfTiles = 43
        
    internal var foregroundColor = Color.primary
        
    public init() {
      foregroundColor = Color(AppTheme.shared.active.navigationTint)
    }
    
    public mutating func updateTheme() {
      foregroundColor = Color(AppTheme.shared.active.navigationTint)
    }
  }
    
  public enum Action: Sendable {
    case update(lines: Int, tiles: Int)
  }
    
  public init() {
        
  }
    
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .update(let lines, let tiles):
        state.numbeOfLines = lines
        state.numberOfTiles = tiles
        return .none
      }
    }
  }
}
