import Foundation

protocol MainUseCaseProtocol {
    associatedtype T
    associatedtype U
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
    func updateItem(
        item: T,
        type: UpdateItemType,
        shouldSaveToLocalCache: Bool,
        completion: @escaping(_ items: [T]?, _ error: SwiftNetworkingError?) -> Void
    )
}

final class MainViewControllerUseCase: MainUseCaseProtocol {
    typealias T = Item
    typealias U = LocalCacheDiff

    private let networking: SwiftNetworking
    private let localCache: ItemsLocalCache
    private let diffCache: DiffLocalCache

    private var isSyncInProgress = false

    /// We'll use a DispatchGroup for all requests to wait their turn in a
    /// serial queue. This way, everytime we call getItems(completion:),
    /// we'll first send any updates available to the network, and then fetch
    /// elements as appropiate.
    private let dispatchGroup = DispatchGroup()

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

        if !isSyncInProgress {
            syncDiffs()
        }

        dispatchGroup.enter()

        networking.get(url: endpoint.path(), parameters: [:], resultType: [T].self) { response, error in
            self.dispatchGroup.leave()

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

        dispatchGroup.wait()
    }

    func updateItem(
        item: T,
        type: UpdateItemType,
        shouldSaveToLocalCache: Bool = true,
        completion: @escaping([T]?, SwiftNetworkingError?
    ) -> Void) {
        let endpoint: Endpoint
        let diffType: UpdateItemType
        switch type {
        case .increment:
            endpoint = .incrementItem
            diffType = .increment
        case .decrement:
            endpoint = .decrementItem
            diffType = .decrement
        }

        let parameters: [EndpointParameter: String] = [
            .id: item.identifier
        ]

        if !isSyncInProgress {
            syncDiffs()
        }

        dispatchGroup.enter()

        networking.post(url: endpoint.path(), parameters: parameters, resultType: [T].self) { items, error in
            self.dispatchGroup.leave()

            guard error == nil, let items = items else {
                if shouldSaveToLocalCache, self.insertToDiffCache(item, type: diffType) {
                    completion(self.getItemsFromLocalCache(), nil)
                } else {
                    completion(nil, .noConnection)
                }
                return
            }

            completion(items, nil)
        }

        dispatchGroup.wait()
    }

    // MARK: - Helpers

    /// Get items from the local cache.
    /// Synchronous, so doesn't care about the DispatchGroup.
    /// It applies diffs over the items for correct values.
    /// - Returns: List of items.
    private func getItemsFromLocalCache() -> [T] {
        let diffs = diffCache.items

        // We'll use a dictionary to avoid a potentially expensive O(n^2) operation.
        // The key is the identifier of an item, and the value the difference to be applied to its count.
        var updates: [String: Int] = [:]

        diffs.forEach { diff in
            let newValue: Int

            if let currentValue = updates[diff.identifier] {
                switch diff.diffType {
                case .increment: newValue = max(0, currentValue + 1)
                case .decrement: newValue = max(0, currentValue - 1)
                }
            } else {
                switch diff.diffType {
                case .increment: newValue = 1
                case .decrement: newValue = -1
                }
            }

            updates[diff.identifier] = newValue
        }

        let items = localCache.items.map { item -> T in
            var newItem = item

            if let diff = updates[item.identifier] {
                newItem.count = item.count + diff
            }

            return newItem
        }

        return items
    }

    /// Updates one item from the ones that we got from the local cache,
    /// and then replaces the whole cache with the updated list.
    /// Synchronous, so doesn't care about the DispatchGroup.
    /// - Parameter item: The `Item` to update, with its `count` already changed.
    /// - Returns: `true` if the record was updated, `false` otherwise.
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
    private func insertToDiffCache(_ item: T, type: UpdateItemType) -> Bool {
        let diffType: LocalCacheDiffType
        switch type {
        case .increment: diffType = .increment
        case .decrement: diffType = .decrement
        }

        let diff = U(identifier: item.identifier, diffType: diffType, uuid: UUID().uuidString)
        return diffCache.saveItems([diff])
    }

    /// Replaces the whole current list of `Item` from the local cache
    /// with a new list.
    /// - Parameter items: The list of `Item`s that will replace the current one in the cache.
    /// - Returns: `true` if replaced correctly, `false` otherwise.
    @discardableResult
    private func saveItemsToLocalCache(_ items: [T]) -> Bool {
        localCache.deleteItems(nil)
        return localCache.saveItems(items)
    }

    private func removeItemFromLocalCache(_ item: T) {
        localCache.deleteItems { $0.identifier == item.identifier }
    }

    private func removeFromDiffCache(_ diff: U) {
        diffCache.deleteItems { $0.uuid == diff.uuid }
    }

    private func removeAllItemsFromDiffCache() {
        diffCache.deleteItems(nil)
    }

    /// Synchronizes the currently saved diffs in the local cache with the server,
    /// and then clears out the list of pending diffs.
    private func syncDiffs() {
        guard !isSyncInProgress else { return }

        isSyncInProgress = true
        let diffs = diffCache.items

        #if DEBUG
        if !diffs.isEmpty {
            print("[\(String(describing: self))] Syncing \(diffs.count) diffs to the backend...")
        }
        #endif

        var successfulUpdates = 0

        diffs.forEach { diff in
            // Updating an item in the backend just requires an identifier,
            // so we'll create a fake `Item` to mimick a save from the Main View.
            let item = Item(
                identifier: diff.identifier,
                title: GlobalConstants.empty,
                count: 0
            )

            let updateType: UpdateItemType
            switch diff.diffType {
            case .increment: updateType = .increment
            case .decrement: updateType = .decrement
            }

            self.dispatchGroup.enter()

            self.updateItem(item: item, type: updateType, shouldSaveToLocalCache: false) { items, error in
                if error == nil, items != nil {
                    successfulUpdates += 1
                    self.removeFromDiffCache(diff)
                }
                self.dispatchGroup.leave()
            }

            self.dispatchGroup.wait()
        }

        #if DEBUG
        if successfulUpdates > 0 {
            print("[\(String(describing: self))] Sync complete. Successful updates: \(successfulUpdates)")
        } else {
            if !diffs.isEmpty {
                print("[\(String(describing: self))] Couldn't sync with the backend.")
            }
        }
        #endif

        isSyncInProgress = false
    }
}
