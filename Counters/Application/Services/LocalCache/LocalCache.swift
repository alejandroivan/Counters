import CoreData
import Foundation

public protocol LocalCache {
    associatedtype T

    /// Gets all the items saved in the cache.
    var items: [T] { get }
    /// Saves all the items passed into the cache.
    func saveItems(_ items: [T]) -> Bool

    /// Deletes items from the cache.
    /// - Parameter filter: A closure that determines if a particular item should be deleted or not.
    /// If `filter` is nil, then all items will be deleted.
    func deleteItems(_ shouldRemove: ((T) -> Bool)?)
}

public extension LocalCache {

    private var dataModelName: String { "LocalCache" }
    var decoder: JSONDecoder { JSONDecoder() }
    var encoder: JSONEncoder { JSONEncoder() }

    // MARK: - Core Data

    private var persistentContainer: NSPersistentContainer {
        let container = NSPersistentContainer(name: dataModelName)

        container.loadPersistentStores { persistentStore, error in
            guard error == nil else {
                preconditionFailure("The LocalCache core data model named \"\(dataModelName)\" can't be accessed.")
            }
        }

        return container
    }

    var managedContext: NSManagedObjectContext { persistentContainer.viewContext }

    func entity(entityName: String) -> NSEntityDescription? {
        NSEntityDescription.entity(forEntityName: entityName, in: managedContext)
    }

    func fetchRequest(entity: NSEntityDescription?) -> NSFetchRequest<NSManagedObject>? {
        guard let entityName = entity?.name else { return nil }
        return NSFetchRequest<NSManagedObject>(entityName: entityName)
    }

    /// Saves the Core Data context.
    /// - Returns: A boolean indicating whether the save was successful or not.
    @discardableResult
    func saveContext() -> Bool {
        guard managedContext.hasChanges else { return true }

        do {
            try managedContext.save()
            return true
        } catch {
            #if DEBUG
            print("Couldn't save the Core Data context: \(error.localizedDescription)")
            #endif

            return false
        }
    }

    // MARK: - Helpers

    func decodableItem<T: Decodable>(from object: NSManagedObject, key: String, type: T.Type) -> T? {
        guard
            let json = object.value(forKey: key) as? String,
            let data = json.data(using: .utf8)
        else { return nil }

        return try? decoder.decode(T.self, from: data)
    }
}
