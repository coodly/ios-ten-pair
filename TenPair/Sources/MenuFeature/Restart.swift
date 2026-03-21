import ComposableArchitecture

@Reducer
public struct Restart {
  @ObservableState
  public struct State: Equatable {
    public let randomLines = [20, 50, 100, 250, 500, 1_000]
        
    public init() {
            
    }
  }
    
  public enum Action: Sendable, ViewAction {
    case delegate(Delegate)
    case view(View)
    
    public enum Delegate: Sendable {
      case startRegular
      case startRandom(Int)
      case close
    }
    
    public enum View: Sendable {
      case tappedRegular
      case tappedRandom(Int)
      case tappedBack
    }
  }
    
  public init() {
        
  }
    
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(let action):
        switch action {
        case .tappedRegular:
          return .send(.delegate(.startRegular))
          
        case .tappedRandom(let number):
          return .send(.delegate(.startRandom(number)))
          
        case .tappedBack:
          return .send(.delegate(.close))
        }
        
      case .delegate:
        return .none
      }
    }
  }
}
