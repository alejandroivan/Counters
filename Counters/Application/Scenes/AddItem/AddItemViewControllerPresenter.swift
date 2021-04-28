import UIKit

final class AddItemViewControllerPresenter: AddItemPresenter {

    weak var viewController: AddItemViewDisplay?

    private(set) var isNetworkOperationInProgress: Bool = false {
        didSet {
            viewController?.mainNavigationController?.updateBars()
        }
    }

    func saveItem(name: String) {
        // TODO: Add user feedback.
        guard name != GlobalConstants.empty else {
            viewController?.setTextFieldError()
            return
        }
        isNetworkOperationInProgress = true
        viewController?.isSaving = true


    }

    func cancelItemCreation() {
        viewController?.dismiss(animated: true, completion: nil)
    }
}

extension AddItemViewControllerPresenter: AddItemViewDelegate {
    func progressIndicatorTextField(_ textField: ProgressIndicatorTextField, isAnimating: Bool) {
        guard let viewController = viewController as? TopBarProvider else { return }
        viewController.topBarLeftItems?.forEach { $0.isEnabled = !isAnimating }
    }

    func didPressExamples() {
        viewController?.routeToExamples()
    }
}
