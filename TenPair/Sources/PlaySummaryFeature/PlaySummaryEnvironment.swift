import ComposableArchitecture

public struct PlaySummaryEnvironment {
    internal let mainQueue: AnySchedulerOf<DispatchQueue>
    public init(mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.mainQueue = mainQueue
    }
}
