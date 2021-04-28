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

    func viewWillAppear() {
        fetchAllItems()
    }
}

extension MainViewControllerPresenter {

    // MARK: - Edit button

    func editItems() {
        print("EDIT ITEMS")
    }

    // MARK: - Add item button

    func addItem() {
        viewController?.routeToAddItem()
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
        items[index].count += 1
        viewController?.displayItems()
    }

    func decrementItem(at index: Int) {
        items[index].count -= 1
        viewController?.displayItems()
    }
}
