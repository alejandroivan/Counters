import Foundation

public class SwiftReachability {

    /// We don't need `SwiftReachability` to have a singleton instance,
    /// but it won't hurt to have the choice. This should be injected
    /// in the majority of use cases, being classes instantiated by the
    /// system the only exceptions (like in `AppDelegate`, where we can't
    /// define the initializer being used).
    static let `default`: SwiftReachability = .init()

    private let reachability: Reachability

    public init(reachability: Reachability = Reachability.forInternetConnection()) {
        self.reachability = reachability
    }

    public var isNetworkReachable: Bool {
        switch reachability.currentReachabilityStatus() {
        case .ReachableViaWiFi, .ReachableViaWWAN: return true
        case .NotReachable: return false
        @unknown default: return false
        }
    }
}
