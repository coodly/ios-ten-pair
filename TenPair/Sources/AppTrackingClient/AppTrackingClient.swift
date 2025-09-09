import Dependencies
import DependenciesMacros

@DependencyClient
public struct AppTrackingClient: Sendable {
  public internal(set) var check: @Sendable () async -> Void
}

extension AppTrackingClient: TestDependencyKey {
  public static var testValue: Self {
    Self()
  }
}

extension DependencyValues {
  public var appTrackingClient: AppTrackingClient {
    get { self[AppTrackingClient.self] }
    set { self[AppTrackingClient.self] = newValue }
  }
}
