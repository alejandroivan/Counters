import Foundation
import XCTest
@testable import Counters

final class SwiftNetworkingTests: XCTestCase {

    private var mockNetworking: NetworkingMock!
    private var mockReachability: ReachabilityMock!
    private var sut: SwiftNetworking!

    override func setUp() {
        super.setUp()
        mockNetworking = NetworkingMock()
        mockReachability = ReachabilityMock()
        sut = SwiftNetworking(
            networking: mockNetworking,
            reachability: SwiftReachability(
                reachability: mockReachability
            )
        )
    }

    override func tearDown() {
        sut = nil
        mockReachability = nil
        mockNetworking = nil
        super.tearDown()
    }

    func testGet_getsListOfObjects() {
        let exp = expectation(description: "Get the list of items")

        sut.get(
            url: "GET_counters_200_single",
            parameters: [:],
            resultType: Items.self
        ) { items, error in
            XCTAssertNotNil(items)
            XCTAssertNil(error)

            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }
}
