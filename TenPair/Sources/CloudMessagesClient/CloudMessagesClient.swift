import Combine

public struct CloudMessagesClient {
    public let feedbackEnabled: Bool
    private let onAllMessages: (() -> AnyPublisher<[Message], Never>)
    private let onCheckForMessages: (() -> Void)
    private let onCheckLoggedIn: (() -> AnyPublisher<Bool, Never>)
    private let onSendMessage: ((String) -> AnyPublisher<Void, Never>)
    private let onUnreadNoticePublisher: (() -> AnyPublisher<Bool, Never>)
    
    public init(
        feedbackEnabled: Bool,
        onAllMessages: @escaping (() -> AnyPublisher<[Message], Never>),
        onCheckForMessages: @escaping (() -> Void),
        onCheckLoggedIn: @escaping (() -> AnyPublisher<Bool, Never>),
        onSendMessage: @escaping ((String) -> AnyPublisher<Void, Never>),
        onUnreadNoticePublisher: @escaping (() -> AnyPublisher<Bool, Never>)
    ) {
        self.feedbackEnabled = feedbackEnabled
        self.onAllMessages = onAllMessages
        self.onCheckForMessages = onCheckForMessages
        self.onCheckLoggedIn = onCheckLoggedIn
        self.onSendMessage = onSendMessage
        self.onUnreadNoticePublisher = onUnreadNoticePublisher
    }
    
    public func allMessages() -> AnyPublisher<[Message], Never> {
        onAllMessages()
    }

    public func checkForMessages() {
        onCheckForMessages()
    }

    public func checkLoggedIn() -> AnyPublisher<Bool, Never> {
        onCheckLoggedIn()
    }

    public func send(message: String) -> AnyPublisher<Void, Never> {
        onSendMessage(message)
    }

    public var unreadNoticePublisher: AnyPublisher<Bool, Never> {
        onUnreadNoticePublisher()
    }
}

extension CloudMessagesClient {
    public static let noFeedback: CloudMessagesClient = CloudMessagesClient(
        feedbackEnabled: false,
        onAllMessages: { PassthroughSubject<[Message], Never>().eraseToAnyPublisher() },
        onCheckForMessages: {},
        onCheckLoggedIn: { Just(false).eraseToAnyPublisher() },
        onSendMessage: { _ in PassthroughSubject<Void, Never>().eraseToAnyPublisher() },
        onUnreadNoticePublisher: { Just(false).eraseToAnyPublisher() }
    )
}
