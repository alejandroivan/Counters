import CoreData
import Foundation

class DiffLocalCache: LocalCache {
    typealias T = LocalCacheDiff
    typealias U = LocalCacheDiffType

    private static var entityName: String { "BackendDiffSync" }
    private static let idKey = "id"
    private static let typeKey = "type"

    public private(set) lazy var managedContext = { persistentContainer.viewContext }()

    var items: [T] { fetchObjects(T.self) }

    @discardableResult
    func saveItems(_ items: [T]) -> Bool {
        guard let entity = self.entity(entityName: Self.entityName) else { return false }

        for item in items {
            let managedObject = NSManagedObject(entity: entity, insertInto: managedContext)
            managedObject.setValue(item.identifier, forKey: Self.idKey)
            managedObject.setValue(item.diffType.rawValue, forKey: Self.typeKey)
            managedContext.insert(managedObject)
        }

        do {
            try managedContext.save()
            return true
        } catch {
            return false
        }
    }

    func deleteItems(_ shouldRemove: ((T) -> Bool)?) {
        let entity = self.entity(entityName: Self.entityName)
        guard let fetchRequest = self.fetchRequest(entity: entity) else { return }
        let allObjects = try? managedContext.fetch(fetchRequest)
        var didDeleteItems = false

        allObjects?.forEach {
            if
                let identifier = $0.value(forKey: Self.idKey) as? String,
                let diffTypeRaw = $0.value(forKey: Self.typeKey) as? String,
                let diffType = U(rawValue: diffTypeRaw)
            {
                let diff = T(identifier: identifier, diffType: diffType)
                let shouldDelete = shouldRemove?(diff) ?? true

                if shouldDelete {
                    didDeleteItems = true
                    managedContext.delete($0)
                }
            }
        }

        if didDeleteItems {
            try? managedContext.save()
        }
    }

    private func fetchObjects(_ type: T.Type) -> [T] {
        let entity = self.entity(entityName: Self.entityName)
        guard let fetchRequest = self.fetchRequest(entity: entity) else { return [] }
        guard let objects = try? managedContext.fetch(fetchRequest) else {
            return []
        }

        let result: [T?] = objects.map {
            guard
                let identifier = $0.value(forKey: Self.idKey) as? String,
                let diffTypeRaw = $0.value(forKey: Self.typeKey) as? String,
                let diffType = U(rawValue: diffTypeRaw)
            else { return nil }

            return T(identifier: identifier, diffType: diffType)
        }

        // We'll use compactMap to ensure there are no nil values
        return result.compactMap { $0 }
    }
}
