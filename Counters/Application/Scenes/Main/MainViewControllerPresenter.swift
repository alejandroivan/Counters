import UIKit

final class MainViewControllerPresenter: MainViewPresenter {
    var items: Items = [
        Item(category: .drink, title: "Piscola", count: 1),
        Item(category: .food, title: "Pizza", count: 2),
        Item(category: .misc, title: "Barcode Scanner", count: 1)
    ]

    weak var viewController: MainViewDisplay?

    func viewDidLoad() {
        // We should present an activity indicator here and fetch data.
        viewController?.presentItems(items)
    }
}

extension MainViewControllerPresenter {

    // MARK: - Edit button

    func editItems() {
        print("EDIT ITEMS")
    }

    // MARK: - Add item button

    func addItem() {
        let newItem = Item(
            category: .drink,
            title: "New item",
            count: 10
        )

        items.append(newItem)
        viewController?.presentItems(items)
    }
}
