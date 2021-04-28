import UIKit

final class AddItemViewControllerPresenter: AddItemPresenter {

    weak var viewController: AddItemViewDisplay?
    private let useCase: AddItemViewControllerUseCase

    init(useCase: AddItemViewControllerUseCase) {
        self.useCase = useCase
    }

    private(set) var isNetworkOperationInProgress: Bool = false {
        didSet {
            viewController?.mainNavigationController?.updateBars()
        }
    }

    func saveItem(name: String) {
        guard name != GlobalConstants.empty else {
            viewController?.setTextFieldError()
            return
        }
        isNetworkOperationInProgress = true
        viewController?.isSaving = true

        useCase.saveItem(name: name) { [weak self] response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self?.isNetworkOperationInProgress = false
                    self?.viewController?.isSaving = false
                    self?.viewController?.showSavingError()
                }
                return
            }

            self?.viewController?.showSavingSuccess()
        }
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
