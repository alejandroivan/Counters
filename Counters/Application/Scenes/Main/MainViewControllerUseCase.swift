import Foundation

protocol MainUseCaseProtocol {
    /// Get items from the network. If there's an error, this will still return
    /// the items from the local cache.
    /// - Parameter completion: Completion handler
    func getItems(completion: @escaping (Items?, SwiftNetworkingError?) -> Void)
}

final class MainViewControllerUseCase: MainUseCaseProtocol {

    private let networking: SwiftNetworking
    private let localCache: ItemsLocalCache

    // MARK: - Initialization

    init(networking: SwiftNetworking, localCache: ItemsLocalCache) {
        self.networking = networking
        self.localCache = localCache
    }

    // MARK: - Use Cases

    func getItems(completion: @escaping (Items?, SwiftNetworkingError?) -> Void) {
        let endpoint: Endpoint = .getItems

        networking.get(url: endpoint.path(), parameters: [:], resultType: Items.self) { response, error in
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

    func incrementItem(id: String, completion: @escaping(Items?, SwiftNetworkingError?) -> Void) {
        let endpoint: Endpoint = .incrementItem

        let parameters: [EndpointParameter: String] = [
            .id: id
        ]

        networking.post(url: endpoint.path(), parameters: parameters, resultType: Items.self) { items, error in
            print("ITEMS: \(items)")
        }
    }

    // MARK: - Helpers

    private func getItemsFromLocalCache() -> Items { localCache.items as! Items }

    @discardableResult
    private func insertOrReplaceFromLocalCache(_ item: Item) -> Bool {
        localCache.saveItems([item])
    }

    @discardableResult
    private func saveItemsToLocalCache(_ items: Items) -> Bool {
        localCache.deleteItems(nil)
        return localCache.saveItems(items)
    }
}
