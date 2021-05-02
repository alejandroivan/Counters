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

    // MARK: - GET

    func testGet_getsListOfObjects() {
        let exp = expectation(description: "Get the list of items")

        sut.get(
            url: "GET_counters_200",
            parameters: [:],
            resultType: Items.self
        ) { items, error in
            XCTAssertNotNil(items)
            XCTAssertNil(error)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }

    func testGet_getsErrorOnResponseFailure() {
        let exp = expectation(description: "Get error when the networking layer can't get a response")
        mockNetworking.shouldFail = true

        sut.get(
            url: "GET_counters_200",
            parameters: [:],
            resultType: Items.self
        ) { items, error in
            XCTAssertNil(items)
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? SwiftNetworkingError, .noConnection)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }

    func testGet_getsErrorOnReachabilityFailure() {
        let exp = expectation(description: "Get error when the Internet connection is off")
        mockReachability.mockReachabilityType = .notReachable

        sut.get(
            url: "GET_counters_200",
            parameters: [:],
            resultType: Items.self
        ) { items, error in
            XCTAssertNil(items)
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? SwiftNetworkingError, .noConnection)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }

    func testGet_getsErrorOnResponseNotCompatibleWithType() {
        let exp = expectation(description: "Get error when the response is not decodable to the type specified")

        sut.get(
            url: "GET_counters_200",
            parameters: [:],
            resultType: Item.self // not decodable since the response is of type `[Item]` = `Items`
        ) { items, error in
            XCTAssertNil(items)
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? SwiftNetworkingError, .notDecodable)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }

    // MARK: - POST

    func testPost_getsListOfObjects() {
        let exp = expectation(description: "POST and get the list of items as response")

        sut.post(
            url: "POST_counter_200",
            parameters: [
                EndpointParameter.id: "a"
            ],
            resultType: Items.self
        ) { items, error in
            XCTAssertNotNil(items)
            XCTAssertNil(error)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }

    func testPost_getsErrorOnResponseFailure() {
        let exp = expectation(description: "Get error when the networking layer can't get a response")
        mockNetworking.shouldFail = true

        sut.post(
            url: "POST_counter_200",
            parameters: [
                EndpointParameter.id: "a"
            ],
            resultType: Items.self
        ) { items, error in
            XCTAssertNil(items)
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? SwiftNetworkingError, .noConnection)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }

    func testPost_getsErrorOnReachabilityFailure() {
        let exp = expectation(description: "Get error when the Internet connection is off")
        mockReachability.mockReachabilityType = .notReachable

        sut.get(
            url: "POST_counter_200",
            parameters: [
                EndpointParameter.id: "a"
            ],
            resultType: Items.self
        ) { items, error in
            XCTAssertNil(items)
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? SwiftNetworkingError, .noConnection)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }

    func testPost_getsErrorOnResponseNotCompatibleWithType() {
        let exp = expectation(description: "Get error when the response is not decodable to the type specified")

        sut.get(
            url: "POST_counter_200",
            parameters: [
                EndpointParameter.id: "a"
            ],
            resultType: Item.self // not decodable since the response is of type `[Item]` = `Items`
        ) { items, error in
            XCTAssertNil(items)
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? SwiftNetworkingError, .notDecodable)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }

    // MARK: - DELETE

    func testDelete_getsListOfObjects() {
        let exp = expectation(description: "DELETE and get the remaining list of items as response")

        sut.delete(
            url: "DELETE_counter_200",
            parameters: [
                EndpointParameter.id: "a"
            ],
            resultType: Items.self
        ) { items, error in
            XCTAssertNotNil(items)
            XCTAssertNil(error)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }

    func testDelete_getsErrorOnResponseFailure() {
        let exp = expectation(description: "Get error when the networking layer can't get a response")
        mockNetworking.shouldFail = true

        sut.delete(
            url: "DELETE_counter_200",
            parameters: [
                EndpointParameter.id: "a"
            ],
            resultType: Items.self
        ) { items, error in
            XCTAssertNil(items)
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? SwiftNetworkingError, .noConnection)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }

    func testDelete_getsErrorOnReachabilityFailure() {
        let exp = expectation(description: "Get error when the Internet connection is off")
        mockReachability.mockReachabilityType = .notReachable

        sut.delete(
            url: "DELETE_counter_200",
            parameters: [
                EndpointParameter.id: "a"
            ],
            resultType: Items.self
        ) { items, error in
            XCTAssertNil(items)
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? SwiftNetworkingError, .noConnection)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }

    func testDelete_getsErrorOnResponseNotCompatibleWithType() {
        let exp = expectation(description: "Get error when the response is not decodable to the type specified")

        sut.delete(
            url: "DELETE_counter_200",
            parameters: [
                EndpointParameter.id: "a"
            ],
            resultType: Item.self // not decodable since the response is of type `[Item]` = `Items`
        ) { items, error in
            XCTAssertNil(items)
            XCTAssertNotNil(error)
            XCTAssertEqual(error as? SwiftNetworkingError, .notDecodable)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }
}
