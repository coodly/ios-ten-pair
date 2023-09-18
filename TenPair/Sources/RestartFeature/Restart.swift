import ComposableArchitecture

public struct Restart: Reducer {
    public struct State: Equatable {
        public let randomLines = [20, 50, 100, 250, 500, 1_000]
        
        public init() {
            
        }
    }
    
    public enum Action {
        case regular
        case random(Int)
        case back
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
