import ComposableArchitecture
import PurchaseFeature
import RestartFeature
import SendFeedbackFeature
import Themes

public let menuReducer = Reducer<MenuState, MenuAction, MenuEnvironment>.combine(
    AnyReducer {
        env in
        
        Purchase()
    }
    .optional()
    .pullback(state: \.purchaseState, action: /MenuAction.purchase, environment: { $0 }),
    AnyReducer {
        env in
        
        Restart()
    }
    .optional()
    .pullback(state: \.restartState, action: /MenuAction.restart, environment: { $0 }),
    sendFeedbackReducer
        .optional()
        .pullback(state: \.sendFeedbackState, action: /MenuAction.sendFeedback, environment: \.sendFeedbackEnv),
    reducer
)

private let reducer = Reducer<MenuState, MenuAction, MenuEnvironment>() {
    state, action, env in
    
    struct MessagesCancellable: Hashable {}
    
    switch action {
    case .willAppear:
        return Effect.concatenate(
            Effect(value: .purchase(.onAppear)),
            Effect(value: .loadMessagesMonitor)
        )
        
    case .willDisappear:
        return Effect.concatenate(
            Effect(value: .purchase(.onDisappear)),
            Effect(value: .unloadMessagesMonitor)
        )
        
    case .resume:
        return .none
        
    case .restartTapped:
        state.restartState = Restart.State()
        return .none
        
    case .theme:
        let next = AppTheme.shared.switchToNext()
        state.activeThemeName = next.localizedName
        return .none
        
    case .restart(.back):
        state.restartState = nil
        return .none
                
    case .loadMessagesMonitor:
        return Effect(env.cloudMessages.unreadNoticePublisher)
            .map(MenuAction.markHasUnread)
            .receive(on: env.mainQueue)
            .eraseToEffect()
            .cancellable(id: MessagesCancellable())
        
    case .unloadMessagesMonitor:
        return Effect.cancel(id: MessagesCancellable())
    
    case .markHasUnread(let hasUnread):
        state.haveUnreadMessage = hasUnread
        return .none
        
    case .feedback:
        state.sendFeedbackState = SendFeedbackState()
        return .none
        
    case .sendFeedback(.onDisappear):
        state.sendFeedbackState = nil
        return .none
        
    case .purchase:
        return .none
    
    case .restart:
        return .none

    case .sendFeedback:
        return .none
    }
}
