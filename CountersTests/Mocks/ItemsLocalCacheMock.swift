import CoreData
import Foundation
@testable import Counters

final class ItemsLocalCacheMock: ItemsLocalCache {

    var shouldSucceed = true
    var shouldReturnEmptyItems = true

    var itemsCalled = false
    var saveItemsCalled = false
    var deleteItemsCalled = false

    override var managedContext: NSManagedObjectContext { persistentContainer.viewContext }

    override var items: [T] {
        itemsCalled = true
        return shouldReturnEmptyItems ? [] : [Item(identifier: "a", title: "a", count: 1)]
    }

    override func saveItems(_ items: [T]) -> Bool {
        saveItemsCalled = true
        return shouldSucceed
    }

    override func deleteItems(_ shouldRemove: ((T) -> Bool)?) {
        deleteItemsCalled = true
        return
    }
}
