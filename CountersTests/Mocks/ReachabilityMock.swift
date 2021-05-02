import Foundation
@testable import Counters

final class ReachabilityMock: Reachability {

    enum ReachabilityType {
        case wifi
        case wwan
        case notReachable
    }
    public var mockReachabilityType: ReachabilityType = .wifi

    override func currentReachabilityStatus() -> NetworkStatus {
        switch mockReachabilityType {
        case .wifi: return .ReachableViaWiFi
        case .wwan: return .ReachableViaWWAN
        case .notReachable: return .NotReachable
        }
    }
}
