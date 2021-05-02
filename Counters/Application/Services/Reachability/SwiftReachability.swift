import Foundation

public class SwiftReachability {

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
