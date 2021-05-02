import Foundation
import XCTest
@testable import Counters

/// NOTE: When running this test case, all items in the cache
/// will be lost. Unfortunately, the cache is shared between DEBUG
/// and TESTING environments.

final class ItemsLocalCacheTests: XCTestCase {

    /// Since this isn't lazy, it runs on initialization, so
    /// we'll clear out the cache before running any tests
    /// (this way, we don't delete on `setUp` which could be
    /// an expensive operation, depending on the number of items
    /// that are already in the cache).
    private var sut: ItemsLocalCache! = {
        let cache = ItemsLocalCache()
        cache.deleteItems { _ -> Bool in true }
        return cache
    }()

    override func setUp() {
        super.setUp()
        sut = ItemsLocalCache()
    }

    override func tearDown() {
        deleteAllCacheItems()
        sut = nil
        super.tearDown()
    }

    // MARK: - Mocks & Helpers

    public static let items: Items = [
        Item(identifier: "a", title: "a", count: 1),
        Item(identifier: "b", title: "b", count: 2),
        Item(identifier: "c", title: "c", count: 3)
    ].sorted { $0.identifier < $1.identifier }

    private func deleteAllCacheItems() {
        sut?.deleteItems { _ -> Bool in true }
    }

    // MARK: - Insert

    func testCacheIsEmpty_onInit() {
        XCTAssertEqual(sut.items.count, 0)
    }

    func testSaveItems_areReturnedByItemsProperty() {
        let expectedItems = Self.items

        sut.saveItems(Self.items)
        let fetchedItems = sut.items.sorted { $0.identifier < $1.identifier}

        XCTAssertEqual(expectedItems.count, fetchedItems.count)
        for i in 0 ..< fetchedItems.count {
            let expected = expectedItems[i]
            let item = fetchedItems[i]
            XCTAssertEqual(expected, item)
        }
    }

    func testDeleteItems_deletesCorrectItem() {
        let identifierToDelete = "b"
        sut.saveItems(Self.items)

        sut.deleteItems { $0.identifier == identifierToDelete }
        let items = sut.items.sorted { $0.identifier < $1.identifier }

        XCTAssertEqual(items.count, Self.items.count - 1)

        var found = false
        for i in 0 ..< Self.items.count {
            let item = Self.items[i]
            guard item.identifier != identifierToDelete else {
                found = true
                continue
            }
            let index = found ? i - 1 : i
            let fetchedItem = items[index]

            XCTAssertEqual(item, fetchedItem)
        }
    }

    func testDeleteItems_deletesAllItemsIfNilClosure() {
        sut.saveItems(Self.items)
        sut.deleteItems(nil)
        XCTAssertEqual(sut.items.count, 0)
    }
}
