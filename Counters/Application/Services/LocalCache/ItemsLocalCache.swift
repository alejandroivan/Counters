import CoreData
import Foundation

class ItemsLocalCache: LocalCache {
    typealias T = Item

    private static var entityName: String { "Counters" }
    private static let jsonKey = "json"

    var items: [T] { fetchObjects(T.self) }

    public private(set) lazy var managedContext: NSManagedObjectContext = { persistentContainer.viewContext }()

    @discardableResult
    func saveItems(_ items: [T]) -> Bool {
        guard let entity = self.entity(entityName: Self.entityName) else { return false }

        for item in items {
            guard
                let data = try? encoder.encode(item),
                let json = String(data: data, encoding: .utf8)
            else { continue }

            let counter = NSManagedObject(entity: entity, insertInto: managedContext)
            counter.setValue(json, forKey: Self.jsonKey)

            managedContext.insert(counter)
        }

        return saveContext()
    }

    func deleteItems(_ shouldRemove: ((T) -> Bool)?) {
        let entity = self.entity(entityName: Self.entityName)
        guard let fetchRequest = self.fetchRequest(entity: entity) else { return }
        let allObjects = try? managedContext.fetch(fetchRequest)
        var didDeleteItems = false

        allObjects?.forEach {
            guard let decodable = decodableItem(from: $0, key: Self.jsonKey, type: T.self) else { return }
            let shouldDelete = shouldRemove?(decodable) ?? true

            if shouldDelete {
                didDeleteItems = true
                managedContext.delete($0)
            }
        }

        if didDeleteItems {
            saveContext()
        }
    }

    private func fetchObjects<T: Decodable>(_ type: T.Type) -> [T] {
        let entity = self.entity(entityName: Self.entityName)
        guard let fetchRequest = self.fetchRequest(entity: entity) else { return [] }
        guard let objects = try? managedContext.fetch(fetchRequest) else {
            return []
        }

        let result: [T?] = objects.map { decodableItem(from: $0, key: Self.jsonKey, type: T.self) }

        // We'll use compactMap to ensure there are no nil values
        return result.compactMap { $0 }
    }
}
