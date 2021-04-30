import UIKit

final class MainViewControllerPresenter: MainPresenter {
    var items: Items = []

    weak var viewController: MainViewDisplay?

    private(set) var tableViewDataSource: MainTableViewDataSource
    private(set) var tableViewDelegate: MainTableViewDelegate
    private let useCase: MainViewControllerUseCase

    private var isLoading = false {
        didSet {
            if isLoading {
                viewController?.showActivityIndicator()
            } else {
                viewController?.hideActivityIndicator()
            }
        }
    }

    init(
        tableViewDataSource: MainTableViewDataSource,
        tableViewDelegate: MainTableViewDelegate,
        useCase: MainViewControllerUseCase
    ) {
        self.useCase = useCase
        self.tableViewDataSource = tableViewDataSource
        self.tableViewDelegate = tableViewDelegate
        self.tableViewDataSource.presenter = self
        self.tableViewDelegate.presenter = self
    }

    func viewDidLoad() {
        fetchAllItems()
    }

    func updateDeleteButtonState() {
        viewController?.refreshDeleteButtonIfNeeded()
    }
}

extension MainViewControllerPresenter {

    // MARK: - Edit button

    func editItems() {
        let isEditing = viewController?.isEditingItems ?? false
        viewController?.setEditingEnabled(!isEditing)
    }

    func removeItems(_ itemsToRemove: Items) {
        guard !isLoading else { return }
        isLoading = true

        useCase.deleteItems(itemsToRemove) { [weak self] items, error in
            self?.isLoading = false
            guard error == nil, let items = items else { return }

            self?.items = items

            DispatchQueue.main.async {
                // Since we're deleting items, there might be the case where the list
                // goes empty. If that's the case, we need to call displayItems() to clear
                // up the tableView, and then show the empty error.
                self?.viewController?.displayItems()
                if items.isEmpty {
                    self?.viewController?.displayEmptyError()
                }
            }
        }
    }

    // MARK: - Add item

    func addItem() {
        viewController?.routeToAddItem()
    }

    func addItemDidFinish(_ addItemView: AddItemViewDisplay?, didCreateItem: Bool) {
        if didCreateItem {
            viewController?.hideErrors()
        }
        fetchAllItems()
    }

    // MARK: - Fetch items

    func fetchAllItems() {
        guard !isLoading else { return }

        viewController?.hideErrors()
        isLoading = true

        useCase.getItems { [weak self] items, error in
            self?.isLoading = false
            
            guard error == nil, let items = items else {
                DispatchQueue.main.async {
                    self?.viewController?.displayNoNetworkError()
                }
                return
            }

            self?.items = items

            DispatchQueue.main.async {
                if items.isEmpty {
                    self?.viewController?.displayEmptyError()
                } else {
                    self?.viewController?.displayItems()
                }
            }
        }
    }

    // MARK: - Counting

    func incrementItem(at index: Int) {
        var item = items[index]
        item.count = item.count + 1
        items[index] = item
        viewController?.displayItems()

        // We don't need a completion handler here, since the useCase will handle
        // all the caching stuff as appropiate. We just tell it to update.
        useCase.updateItem(item: item, type: .increment) { _, _ in }
    }

    func decrementItem(at index: Int) {
        var item = items[index]
        item.count = item.count - 1
        items[index] = item
        viewController?.displayItems()

        // We don't need a completion handler here, since the useCase will handle
        // all the caching stuff as appropiate. We just tell it to update.
        useCase.updateItem(item: item, type: .decrement) { _, _ in }
    }
}
