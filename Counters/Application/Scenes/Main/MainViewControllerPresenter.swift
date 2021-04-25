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
        viewController?.displayItems()
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
