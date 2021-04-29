import Foundation

protocol MainUseCaseProtocol {
    /// Get items from the network. If there's an error, this will still return
    /// the items from the local cache.
    /// - Parameter completion: Completion handler
    func getItems(completion: @escaping (Items?, SwiftNetworkingError?) -> Void)

    /// Get all the items stored in the local cache.
    func getItemsFromLocalCache() -> Items

    /// Save items to the local cache.
    /// - Parameter items: The list of items to be saved.
    @discardableResult
    func saveItemsToLocalCache(_ items: Items) -> Bool
}

final class MainViewControllerUseCase: MainUseCaseProtocol {

    private enum Endpoint: String {
        case getItems = "v1/counters"
    }

    private let networking: SwiftNetworking
    private let localCache: LocalCache

    // MARK: - Initialization

    init(networking: SwiftNetworking, localCache: LocalCache) {
        self.networking = networking
        self.localCache = localCache
    }

    // MARK: - Use Cases

    func getItems(completion: @escaping (Items?, SwiftNetworkingError?) -> Void) {
        let url: Endpoint = .getItems

        networking.get(url: url.rawValue, parameters: [:], resultType: Items.self) { response, error in
            guard error == nil else {
                let items = self.localCache.items

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

    func getItemsFromLocalCache() -> Items { localCache.items }

    @discardableResult
    func saveItemsToLocalCache(_ items: Items) -> Bool { localCache.saveItems(items) }
}
