import ComposableArchitecture
import MenuFeature
import PlaySummaryFeature

public let playReducer = Reducer<PlayState, PlayAction, PlayEnvironment>.combine(
    AnyReducer {
        env in
        
        Menu()
    }
    .optional()
    .pullback(state: \.menuState, action: /PlayAction.menu, environment: { $0 }),
    playSummaryReducer.pullback(state: \.playSummaryState, action: /PlayAction.playSummary, environment: \.playSummaryEnv),
    reducer
)

private let reducer = Reducer<PlayState, PlayAction, PlayEnvironment>() {
    state, action, env in
    
    switch action {
    case .tappedMenu:
        state.restartAction = nil
        state.menuState = Menu.State(
            feedbackEnabled: env.cloudMessages.feedbackEnabled,
            havePurchase: env.purchaseClient.havePurchase
        )
        return .none
    
    case .tappedReload:
        return .none
        
    case .tappedHint:
        return .none
        
    case .sendRateEvent:
        env.rateAppClient.maybeRateEvent()
        return .none
        
    case .menu(.resume):
        state.menuState = nil
        return .none
    
    case .menu(.restart(.regular)):
        state.restartAction = .regular
        state.menuState = nil
        return Effect(value: .sendRateEvent)
        
    case .menu(.restart(.random(let lines))):
        state.restartAction = .random(lines)
        state.menuState = nil
        return Effect(value: .sendRateEvent)

    case .menu:
        return .none
        
    case .playSummary:
        return .none
    }
}
