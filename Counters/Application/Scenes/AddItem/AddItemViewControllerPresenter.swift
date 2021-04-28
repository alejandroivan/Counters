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
        guard name != GlobalConstants.empty else { return }
        isNetworkOperationInProgress = true
        viewController?.isSaving = true

        
    }

    func cancelItemCreation() {
        viewController?.dismiss(animated: true, completion: nil)
    }
}

extension AddItemViewControllerPresenter: AddItemViewDelegate {
    func progressIndicatorTextField(_ textField: ProgressIndicatorTextField, isAnimating: Bool) {
        print("\(textField) animating: \(isAnimating)")
    }

    func didPressExamples() {
        viewController?.routeToExamples()
    }
}
