import ComposableArchitecture
import SwiftUI
import Themes

@Reducer
public struct ButtonTray: Sendable {
  @ObservableState
  public struct State: Sendable, Equatable {
    public var backgroundColor = Color.primary
    public var foregroundColor = Color.primary
    
    public init() {
      updateTheme()
    }
    
    public mutating func updateTheme() {
      backgroundColor = Color(AppTheme.shared.active.main)
      foregroundColor = Color(AppTheme.shared.active.text)
    }
  }
  
  public enum Action: Sendable {
    
  }
  
  public init() {
    
  }
  
  public var body: some ReducerOf<Self> {
    Reduce {
      state, action in
      
      return .none
    }
  }
}

