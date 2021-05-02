import Foundation
import XCTest
@testable import Counters

final class SwiftReachabilityTests: XCTestCase {

    private var mock: ReachabilityMock!
    private var sut: SwiftReachability!

    override func setUp() {
        super.setUp()
        mock = ReachabilityMock()
        sut = SwiftReachability(reachability: mock)
    }

    override func tearDown() {
        sut = nil
        mock = nil
        super.tearDown()
    }

    // MARK: - Test Reachability cases

    func testReachable_viaWifi() {
        mock.mockReachabilityType = .wifi
        XCTAssertTrue(sut.isNetworkReachable)
    }

    func testReachable_viaWWAN() {
        mock.mockReachabilityType = .wwan
        XCTAssertTrue(sut.isNetworkReachable)
    }

    func testNotReachable() {
        mock.mockReachabilityType = .notReachable
        XCTAssertFalse(sut.isNetworkReachable)
    }
}
