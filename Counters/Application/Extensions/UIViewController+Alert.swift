import UIKit

public extension UIViewController {

    struct Constants {
        public struct Alert {
            static let tintColor = UIColor.counters.accent
            public static let cancelTitle = "ALERT_ACTION_CANCEL".localized
        }
    }

    func showAlert(
        title: String?,
        message: String?,
        actionTitle: String,
        cancelTitle: String? = Constants.Alert.cancelTitle,
        style: UIAlertController.Style = .alert,
        actionType: UIAlertAction.Style = .cancel,
        action: ((UIAlertAction) -> Void)?,
        showsCancelButton: Bool = true,
        cancelAction: ((UIAlertAction) -> Void)? = { _ in }
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: style
        )

        alertController.addAction(
            UIAlertAction(
                title: actionTitle,
                style: actionType,
                handler: { actionHandler in
                    DispatchQueue.main.async {
                        action?(actionHandler)
                    }
                }
            )
        )

        if showsCancelButton {
            alertController.addAction(
                UIAlertAction(
                    title: cancelTitle,
                    style: .cancel,
                    handler: { actionHandler in
                        cancelAction?(actionHandler)
                    }
                )
            )
        }

        alertController.view.tintColor = Constants.Alert.tintColor
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
}
