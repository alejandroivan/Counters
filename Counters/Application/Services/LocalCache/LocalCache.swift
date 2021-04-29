import CoreData
import Foundation

protocol Cache {
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

final class LocalCache {

    private static let dataModelName = "LocalCache"
    private static let entityName = "Counters"
    private static let jsonKey = "json"
    private static let decoder = JSONDecoder()
    private static let encoder = JSONEncoder()

    // MARK: - Core Data

    private static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: dataModelName)

        container.loadPersistentStores { persistentStore, error in
            guard error == nil else {
                preconditionFailure("The LocalCache core data model named \"\(dataModelName)\" can't be accessed.")
            }
        }

        return container
    }()

    private var persistentContainer: NSPersistentContainer { Self.persistentContainer }
    private var managedContext: NSManagedObjectContext { persistentContainer.viewContext }

    private lazy var entity: NSEntityDescription? = {
        NSEntityDescription.entity(forEntityName: Self.entityName, in: managedContext)
    }()

    private var fetchRequest: NSFetchRequest<NSManagedObject> { NSFetchRequest<NSManagedObject>(entityName: Self.entityName) }

    /// Saves the Core Data context.
    /// - Returns: A boolean indicating whether the save was successful or not.
    @discardableResult
    private func saveContext() -> Bool {
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

    private func fetchObjects<T: Decodable>(_ type: T.Type) -> [T] {
        guard let objects = try? managedContext.fetch(fetchRequest) else {
            return []
        }

        let result: [T?] = objects.map { decodableItem(from: $0, type: T.self) }

        // We'll use compactMap to ensure there are no nil values
        return result.compactMap { $0 }
    }

    private func decodableItem<T: Decodable>(from object: NSManagedObject, type: T.Type) -> T? {
        guard
            let json = object.value(forKey: Self.jsonKey) as? String,
            let data = json.data(using: .utf8)
        else { return nil }

        return try? Self.decoder.decode(T.self, from: data)
    }
}

extension LocalCache: Cache {
    typealias T = Item

    var items: [T] { fetchObjects(T.self) }

    @discardableResult
    func saveItems(_ items: [T]) -> Bool {
        guard let entity = self.entity else { return false }

        for item in items {
            guard
                let data = try? Self.encoder.encode(item),
                let json = String(data: data, encoding: .utf8)
            else { continue }

            let counter = NSManagedObject(entity: entity, insertInto: managedContext)
            counter.setValue(json, forKey: Self.jsonKey)

            managedContext.insert(counter)
        }

        do {
            try managedContext.save()
            return true
        } catch {
            return false
        }
    }

    func deleteItems(_ shouldRemove: ((T) -> Bool)?) {
        let allObjects = try? managedContext.fetch(fetchRequest)
        var didDeleteItems = false

        allObjects?.forEach {
            guard let decodable = decodableItem(from: $0, type: T.self) else { return }
            let shouldDelete = shouldRemove?(decodable) ?? true

            if shouldDelete {
                didDeleteItems = true
                managedContext.delete($0)
            }
        }

        if didDeleteItems {
            try? managedContext.save()
        }
    }
}
