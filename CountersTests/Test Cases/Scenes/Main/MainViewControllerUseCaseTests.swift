import Foundation
import XCTest
@testable import Counters

final class MainViewControllerUseCaseTests: XCTestCase {

    private var sut: MainViewControllerUseCase!
    private var mockNetworking: NetworkingMock!
    private var mockReachability: ReachabilityMock!
    private var mockLocalCache: ItemsLocalCacheMock!
    private var mockDiffCache: DiffLocalCacheMock!

    override func setUp() {
        super.setUp()
        mockNetworking = NetworkingMock()
        mockReachability = ReachabilityMock()
        mockLocalCache = ItemsLocalCacheMock()
        mockDiffCache = DiffLocalCacheMock()
        mockLocalCache.shouldReturnEmptyItems = true
        mockDiffCache.shouldReturnEmptyItems = true
        sut = MainViewControllerUseCase(
            networking: SwiftNetworking(
                networking: mockNetworking,
                reachability: SwiftReachability(
                    reachability: mockReachability
                )
            ),
            localCache: mockLocalCache,
            diffCache: mockDiffCache
        )
    }

    override func tearDown() {
        sut = nil
        mockDiffCache = nil
        mockLocalCache = nil
        mockReachability = nil
        mockNetworking = nil
        super.tearDown()
    }

    // MARK: - Get items

    func testGetItems_callsGetOnTheNetworkLayer() {
        let exp = expectation(description: "The use case should call the network for a item list")

        sut.getItems { items, error in
            XCTAssertNotNil(items)
            XCTAssertGreaterThan(items?.count ?? 0, 0)
            XCTAssertNil(error)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)

        // Every use case network call should have `mockDiffCache.itemsCalled` set to `true`,
        // since we do a synchronization before actually making the call (that's why we have
        // all that DispatchGroup logic involved in there).
        XCTAssertTrue(mockDiffCache.itemsCalled)
        XCTAssertFalse(mockLocalCache.itemsCalled)
    }

    func testGetItems_errorGetsItemsFromLocalCache() {
        // NOTE: The local cache is empty.
        mockLocalCache.shouldReturnEmptyItems = false
        mockNetworking.shouldFail = true

        let exp = expectation(description: """
        When the network fails, we should get the items from the local cache.
        """)

        sut.getItems { items, error in
            XCTAssertNotNil(items)
            XCTAssertGreaterThan(items?.count ?? 0, 0)
            XCTAssertNil(error)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)

        // Every use case network call should have `mockDiffCache.itemsCalled` set to `true`,
        // since we do a synchronization before actually making the call (that's why we have
        // all that DispatchGroup logic involved in there).
        XCTAssertTrue(mockDiffCache.itemsCalled)
        XCTAssertTrue(mockLocalCache.itemsCalled)
    }

    func testGetItems_errorGetsEmptyItemsFromLocalCache() {
        // NOTE: The local cache is empty.
        mockLocalCache.shouldReturnEmptyItems = true
        mockNetworking.shouldFail = true

        let exp = expectation(description: """
        When the network fails, we should get the items from the local cache.
        If there are no items in the local cache, then the call should return a `SwiftNetworkingError`.
        """)

        sut.getItems { items, error in
            XCTAssertNil(items)
            XCTAssertNotNil(error)
            XCTAssertEqual(error, .noConnection)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)

        // Every use case network call should have `mockDiffCache.itemsCalled` set to `true`,
        // since we do a synchronization before actually making the call (that's why we have
        // all that DispatchGroup logic involved in there).
        XCTAssertTrue(mockDiffCache.itemsCalled)
        // If the network fails, the local cache should have its items fetched (access `localCache.items`).
        XCTAssertTrue(mockLocalCache.itemsCalled)
    }

    // MARK: - Update items

    func testUpdateItem_networkErrorSavesIntoDiffCache() {
        let item = Item(identifier: "a", title: "a", count: 1)
        mockNetworking.shouldFail = true
        mockLocalCache.shouldReturnEmptyItems = false
        mockDiffCache.shouldReturnEmptyItems = false
        let exp = expectation(description: "Calling updateItem with no ocnnection should save the change into the diffCache")

        sut.updateItem(
            item: item,
            type: .increment
        ) { items, error in
            XCTAssertNotNil(items)
            XCTAssertNil(error)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)

        XCTAssertTrue(mockLocalCache.itemsCalled)
        XCTAssertTrue(mockDiffCache.itemsCalled)
        XCTAssertTrue(mockDiffCache.saveItemsCalled)
    }

    func testUpdateItem_networkErrorAndSavingToLocalCacheDisabledShouldReturnError() {
        let item = Item(identifier: "a", title: "a", count: 1)
        mockNetworking.shouldFail = true
        let exp = expectation(description: "Calling updateItem with .increment should call the correct endpoint")

        sut.updateItem(
            item: item,
            type: .increment,
            shouldSaveToLocalCache: false
        ) { items, error in
            XCTAssertNil(items)
            XCTAssertNotNil(error)
            XCTAssertEqual(error, .noConnection)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)

        XCTAssertTrue(mockDiffCache.itemsCalled)
    }

    func testUpdateItem_incrementGetsItemsRefreshed() {
        let item = Item(identifier: "a", title: "a", count: 1)
        let exp = expectation(description: "Calling updateItem with .increment should call the correct endpoint")

        sut.updateItem(
            item: item,
            type: .increment
        ) { items, error in
            XCTAssertNotNil(items)
            XCTAssertNotEqual(items?.first?.count, item.count)
            XCTAssertNil(error)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)

        XCTAssertTrue(mockDiffCache.itemsCalled)
    }

    func testUpdateItem_decrementGetsItemsRefreshed() {
        let item = Item(identifier: "a", title: "a", count: 1)
        let exp = expectation(description: "Calling updateItem with .decrement should call the correct endpoint")

        sut.updateItem(
            item: item,
            type: .decrement
        ) { items, error in
            XCTAssertNotNil(items)
            XCTAssertNotEqual(items?.first?.count, item.count)
            XCTAssertNil(error)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)

        XCTAssertTrue(mockDiffCache.itemsCalled)
    }

    // MARK: - Delete items

    func testDeleteItems_deleteGetsItemsRefreshed() {
        let item = Item(identifier: "b", title: "b", count: 2)
        let exp = expectation(description: "Calling updateItem with .delete should get the refreshed list")

        sut.deleteItems([item]) { items, error in
            XCTAssertNotNil(items)
            XCTAssertNil(error)

            items?.forEach {
                XCTAssertNotEqual($0.identifier, item.identifier)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)
    }

    func testDeleteItems_networkErrorShouldSaveDiffToDiffCache() {
        let item = Item(identifier: "b", title: "b", count: 2)
        mockNetworking.shouldFail = true
        mockLocalCache.shouldReturnEmptyItems = false
        mockDiffCache.shouldReturnEmptyItems = false
        let exp = expectation(description: "The internet connectivity error should save into diff cache for uploading later")

        sut.deleteItems([item]) { items, error in
            XCTAssertNotNil(items)
            XCTAssertNil(error)

            items?.forEach {
                XCTAssertNotEqual($0.identifier, item.identifier)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)

        XCTAssertTrue(mockLocalCache.itemsCalled)
        XCTAssertFalse(mockLocalCache.saveItemsCalled)
        XCTAssertTrue(mockDiffCache.itemsCalled)
        XCTAssertTrue(mockDiffCache.saveItemsCalled)
    }

    func testDeleteItems_networkErrorWithNoCacheShouldReturnError() {
        let item = Item(identifier: "b", title: "b", count: 2)
        mockNetworking.shouldFail = true
        mockDiffCache.shouldSucceed = false
        let exp = expectation(description: """
        The internet connectivity error should try to save into diff cache for uploading later.
        If the cache fails saving the diff, it should return a network error, indicating it failed.
        """)

        sut.deleteItems([item]) { items, error in
            XCTAssertNil(items)
            XCTAssertNotNil(error)

            items?.forEach {
                XCTAssertNotEqual($0.identifier, item.identifier)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 3)

        XCTAssertTrue(mockDiffCache.itemsCalled)
        XCTAssertTrue(mockDiffCache.saveItemsCalled)
    }
}
