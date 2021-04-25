import UIKit

final class AddItemViewControllerPresenter: AddItemPresenter {

    weak var viewController: AddItemViewDisplay?

    private(set) var isNetworkOperationInProgress: Bool = false {
        didSet {
            viewController?.mainNavigationController?.updateBars()
        }
    }

    func viewDidLoad() {
        // We should present an activity indicator here and fetch data.
        print("Presenter initialized.")
    }

    func saveItem() {
        isNetworkOperationInProgress = true
        print("SAVE!")
    }

    func cancelItemCreation() {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
