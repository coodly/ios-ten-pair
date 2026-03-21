import AppTrackingClient
import AppTrackingTransparency
import Dependencies

extension AppTrackingClient: DependencyKey {
  public static var liveValue: AppTrackingClient {
    AppTrackingClient(
      check: {
        await withCheckedContinuation { completion in
          guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else {
            completion.resume()
            return
          }

          ATTrackingManager.requestTrackingAuthorization { _ in
            completion.resume()
          }
        }
      }
    )
  }
}
