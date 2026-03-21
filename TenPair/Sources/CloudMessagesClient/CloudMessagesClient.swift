import Combine
import Dependencies
import XCTestDynamicOverlay

public struct CloudMessagesClient {
  public let feedbackEnabled: Bool
  private let onCheckForMessages: () async -> Void
  private let onCheckLoggedIn: () async -> Bool
  private let onSendMessage: ((String) -> AnyPublisher<Void, Never>)

  public init(
    feedbackEnabled: Bool,
    onCheckForMessages: @escaping () async -> Void,
    onCheckLoggedIn: @escaping () async -> Bool,
    onSendMessage: @escaping ((String) -> AnyPublisher<Void, Never>)
  ) {
    self.feedbackEnabled = feedbackEnabled
    self.onCheckForMessages = onCheckForMessages
    self.onCheckLoggedIn = onCheckLoggedIn
    self.onSendMessage = onSendMessage
  }

  public func checkForMessages() async {
    await onCheckForMessages()
  }

  public func checkLoggedIn() async -> Bool {
    await onCheckLoggedIn()
  }

  public func send(message: String) -> AnyPublisher<Void, Never> {
    onSendMessage(message)
  }
}

extension CloudMessagesClient {
  public static let noFeedback: CloudMessagesClient = CloudMessagesClient(
    feedbackEnabled: false,
    onCheckForMessages: {},
    onCheckLoggedIn: { false },
    onSendMessage: { _ in PassthroughSubject<Void, Never>().eraseToAnyPublisher() }
  )
}

extension CloudMessagesClient: TestDependencyKey {
  public static var testValue: CloudMessagesClient {
    CloudMessagesClient(
      feedbackEnabled: false,
      onCheckForMessages: unimplemented("\(Self.self).onCheckForMessages"),
      onCheckLoggedIn: unimplemented("\(Self.self).onCheckLoggedIn"),
      onSendMessage: unimplemented("\(Self.self).onSendMessage")
    )
  }
}

extension DependencyValues {
  public var cloudMessagesClient: CloudMessagesClient {
    get { self[CloudMessagesClient.self] }
    set { self[CloudMessagesClient.self] = newValue }
  }
}
