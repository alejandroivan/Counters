import CoreData
import Foundation

protocol Cache {
    associatedtype T

    var items: [T] { get }
    func saveItems(_ items: [T]) -> Bool
}

final class LocalCache {

    private static let dataModelName = "LocalCache"
    private static let entityName = "Counters"
    private static let jsonKey = "json"

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

        let decoder = JSONDecoder()

        let result: [T?] = objects.map {
            guard
                let json = $0.value(forKey: Self.jsonKey) as? String,
                let data = json.data(using: .utf8)
            else { return nil }

            return try? decoder.decode(T.self, from: data)
        }

        // We'll use compactMap to ensure there are no nil values
        return result.compactMap { $0 }
    }
}

extension LocalCache: Cache {

    var items: [Item] { fetchObjects(T.self) }

    @discardableResult
    func saveItems(_ items: [Item]) -> Bool {
        guard let entity = self.entity else { return false }

        let encoder = JSONEncoder()
        var result = true

        for item in items {
            guard
                let data = try? encoder.encode(item),
                let json = String(data: data, encoding: .utf8)
            else { continue }

            let counter = NSManagedObject(entity: entity, insertInto: managedContext)
            counter.setValue(json, forKey: Self.jsonKey)

            result = result && saveContext()
        }

        return result
    }
}
