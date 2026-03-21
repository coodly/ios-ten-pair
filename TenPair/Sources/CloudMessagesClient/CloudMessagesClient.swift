import Combine
import Dependencies
import DependenciesMacros

@DependencyClient
public struct CloudMessagesClient: Sendable {
  public internal(set) var feedbackEnabled: @Sendable () -> Bool = { false }
  public internal(set) var onCheckForMessages: @Sendable () async -> Void
  public internal(set) var onCheckLoggedIn: @Sendable () async -> Bool = { false }
  public internal(set) var onSendMessage: @Sendable (String) async -> String? = { _ in nil }

  public func checkForMessages() async {
    await onCheckForMessages()
  }

  public func checkLoggedIn() async -> Bool {
    await onCheckLoggedIn()
  }

  public func send(message: String) async -> String? {
    await onSendMessage(message)
  }
}

extension CloudMessagesClient {
  public static let noFeedback: CloudMessagesClient = CloudMessagesClient(
    feedbackEnabled: { false },
    onCheckForMessages: {},
    onCheckLoggedIn: { false },
    onSendMessage: { _ in nil }
  )
}

extension CloudMessagesClient: TestDependencyKey {
  public static var testValue: CloudMessagesClient {
    Self()
  }
}

extension DependencyValues {
  public var cloudMessagesClient: CloudMessagesClient {
    get { self[CloudMessagesClient.self] }
    set { self[CloudMessagesClient.self] = newValue }
  }
}
