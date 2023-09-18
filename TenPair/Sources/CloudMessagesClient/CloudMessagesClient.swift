import Combine
import Dependencies
import XCTestDynamicOverlay

public struct CloudMessagesClient {
    public let feedbackEnabled: Bool
    private let onAllMessages: (() -> AnyPublisher<[Message], Never>)
    private let onCheckForMessages: (() -> Void)
    private let onCheckLoggedIn: () async -> Bool
    private let onSendMessage: ((String) -> AnyPublisher<Void, Never>)
    private let onUnreadNoticePublisher: (() -> AnyPublisher<Bool, Never>)
    
    public init(
        feedbackEnabled: Bool,
        onAllMessages: @escaping (() -> AnyPublisher<[Message], Never>),
        onCheckForMessages: @escaping (() -> Void),
        onCheckLoggedIn: @escaping () async -> Bool,
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

    public func checkLoggedIn() async -> Bool {
        await onCheckLoggedIn()
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
        onCheckLoggedIn: { false },
        onSendMessage: { _ in PassthroughSubject<Void, Never>().eraseToAnyPublisher() },
        onUnreadNoticePublisher: { Just(false).eraseToAnyPublisher() }
    )
}

extension CloudMessagesClient: TestDependencyKey {
    public static var testValue: CloudMessagesClient {
        CloudMessagesClient(
            feedbackEnabled: false,
            onAllMessages: unimplemented("\(Self.self).onAllMessages"),
            onCheckForMessages: unimplemented("\(Self.self).onCheckForMessages"),
            onCheckLoggedIn: unimplemented("\(Self.self).onCheckLoggedIn"),
            onSendMessage: unimplemented("\(Self.self).onSendMessage"),
            onUnreadNoticePublisher: unimplemented("\(Self.self).onUnreadNoticePublisher")
        )
    }
}

extension DependencyValues {
    public var cloudMessagesClient: CloudMessagesClient {
        get { self[CloudMessagesClient.self] }
        set { self[CloudMessagesClient.self] = newValue }
    }
}
