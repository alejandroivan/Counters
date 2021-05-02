import CoreData
import Foundation
@testable import Counters

final class DiffLocalCacheMock: DiffLocalCache {

    var shouldSucceed = true
    var shouldReturnEmptyItems = true
    
    var itemsCalled = false
    var saveItemsCalled = false
    var deleteItemsCalled = false

    override var managedContext: NSManagedObjectContext { persistentContainer.viewContext }

    override var items: [T] {
        itemsCalled = true
        return shouldReturnEmptyItems ? [] : [
            LocalCacheDiff(identifier: "a", diffType: .increment, uuid: "a"),
            LocalCacheDiff(identifier: "a", diffType: .decrement, uuid: "b"),
            LocalCacheDiff(identifier: "a", diffType: .delete, uuid: "c")
        ]
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
