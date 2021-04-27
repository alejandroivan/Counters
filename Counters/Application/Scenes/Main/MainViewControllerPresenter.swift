import UIKit

final class MainViewControllerPresenter: MainPresenter {
    var items: Items = []

    weak var viewController: MainViewDisplay?
    private(set) var dataSource: MainTableViewDataSource

    init(dataSource: MainTableViewDataSource) {
        self.dataSource = dataSource
        self.dataSource.presenter = self
    }

    func viewDidLoad() {
        // We should present an activity indicator here and fetch data.
        SwiftNetworking.get(url: "v1/counters", parameters: ["a": "b"], resultType: Items.self) { [weak self] items, error in
            guard error == nil, let items = items else {
                print("ERROR: \(String(describing: error))")
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
}
