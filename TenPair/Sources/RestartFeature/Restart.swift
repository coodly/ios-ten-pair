import ComposableArchitecture

public struct Restart: ReducerProtocol {
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
    
    public var body: some ReducerProtocolOf<Self> {
        Reduce {
            state, action in
            
            return .none
        }
    }
}
