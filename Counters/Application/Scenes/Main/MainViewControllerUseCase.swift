import Foundation

protocol MainUseCaseProtocol {
    associatedtype T
    associatedtype UpdateItemType

    /// Get items from the network. If there's an error, this will still return
    /// the items from the local cache.
    /// - Parameters:
    ///   - completion: Closure to be called when the network/cache operations end.
    ///   - items: The updated list of items, or `nil` if an error occurs.
    ///   - error: A `SwiftNetworkingError` in case the list of `items` could not be fetched.
    func getItems(completion: @escaping (_ items: [T]?, _ error: SwiftNetworkingError?) -> Void)

    /// Updates the count for an Item, filtering by its identifier.
    /// - Parameters:
    ///   - item: The item to update.
    ///   - completion: Closure to be called when the network/cache operations end.
    ///   - items: The updated list of items, or `nil` if an error occurs.
    ///   - error: A `SwiftNetworkingError` in case the list of `items` could not be fetched after the update.
    func updateItem(item: T, type: UpdateItemType, completion: @escaping(_ items: [T]?, _ error: SwiftNetworkingError?) -> Void)
}

final class MainViewControllerUseCase: MainUseCaseProtocol {
    typealias T = Item

    private let networking: SwiftNetworking
    private let localCache: ItemsLocalCache
    private let diffCache: DiffLocalCache

    public enum UpdateItemType {
        case increment
        case decrement
    }

    // MARK: - Initialization

    init(networking: SwiftNetworking, localCache: ItemsLocalCache, diffCache: DiffLocalCache) {
        self.networking = networking
        self.localCache = localCache
        self.diffCache = diffCache
    }

    // MARK: - Use Cases

    func getItems(completion: @escaping ([T]?, SwiftNetworkingError?) -> Void) {
        let endpoint: Endpoint = .getItems

        networking.get(url: endpoint.path(), parameters: [:], resultType: [T].self) { response, error in
            guard error == nil else {
                let items = self.getItemsFromLocalCache()

                if items.isEmpty {
                    completion(nil, error as? SwiftNetworkingError)
                } else {
                    completion(items, nil)
                }
                return
            }

            let itemsToSave = response ?? []
            self.saveItemsToLocalCache(itemsToSave)

            completion(response, nil)
        }
    }

    func updateItem(item: T, type: UpdateItemType, completion: @escaping([T]?, SwiftNetworkingError?) -> Void) {
        let endpoint: Endpoint
        switch type {
        case .increment: endpoint = .incrementItem
        case .decrement: endpoint = .decrementItem
        }

        let parameters: [EndpointParameter: String] = [
            .id: item.identifier
        ]

        networking.post(url: endpoint.path(), parameters: parameters, resultType: [T].self) { items, error in
            guard error == nil, let items = items else {
                if self.insertOrReplaceFromLocalCache(item) {
                    completion(self.getItemsFromLocalCache(), nil)
                } else {
                    completion(nil, .noConnection)
                }
                return
            }

            completion(items, nil)
        }
    }

    // MARK: - Helpers

    private func getItemsFromLocalCache() -> [T] { localCache.items }

    @discardableResult
    private func insertOrReplaceFromLocalCache(_ item: T) -> Bool {
        let items = localCache.items.map { (current: T) -> T in
            guard current.identifier == item.identifier else { return current }
            var newItem = current
            newItem.count = item.count
            return newItem
        }

        return saveItemsToLocalCache(items)
    }

    @discardableResult
    private func saveItemsToLocalCache(_ items: [T]) -> Bool {
        localCache.deleteItems(nil)
        return localCache.saveItems(items)
    }
}
