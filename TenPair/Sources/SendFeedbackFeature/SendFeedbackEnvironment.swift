import CloudMessagesClient
import ComposableArchitecture

public struct SendFeedbackEnvironment {
    internal let cloudMessagesClient: CloudMessagesClient
    internal let mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        cloudMessagesClient: CloudMessagesClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.cloudMessagesClient = cloudMessagesClient
        self.mainQueue = mainQueue
    }
}
