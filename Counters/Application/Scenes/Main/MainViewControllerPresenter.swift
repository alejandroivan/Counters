import UIKit

final class MainViewControllerPresenter: MainPresenter {
    var items: Items = []

    weak var viewController: MainViewDisplay?

    private(set) var tableViewDataSource: MainTableViewDataSource
    private(set) var tableViewDelegate: MainTableViewDelegate
    private let useCase: MainViewControllerUseCase

    private var isLoading = false

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
}

extension MainViewControllerPresenter {

    // MARK: - Edit button

    func editItems() {
        let isEditing = viewController?.isEditingItems ?? false
        viewController?.setEditingEnabled(!isEditing)
    }

    // MARK: - Add item

    func addItem() {
        viewController?.routeToAddItem()
    }

    func addItemDidFinish(_ addItemView: AddItemViewDisplay?) {
        fetchAllItems()
    }

    // MARK: - Fetch items

    func fetchAllItems() {
        guard !isLoading else { return }

        isLoading = true

        useCase.getItems { [weak self] items, error in
            self?.isLoading = false
            
            guard error == nil, let items = items else {
                self?.viewController?.displayNoNetworkError()
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
        /// This login shouldn't be needed, but if we, for some weird reason, get into the
        /// integer overflow limit, we'll get back to 0 and NOT the least negative number.
        let newCount = items[index].count + 1
        items[index].count = max(0, newCount)
        viewController?.displayItems()
    }

    func decrementItem(at index: Int) {
        let newCount = items[index].count - 1
        items[index].count = max(0, newCount)
        viewController?.displayItems()
    }
}
