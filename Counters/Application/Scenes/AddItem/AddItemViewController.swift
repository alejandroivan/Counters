import UIKit

final class AddItemViewController: UIViewController, TopBarProvider {

    private let presenter: AddItemPresenter
    private let sourcePresenter: MainPresenter

    private lazy var addItemView: AddItemView = {
        let viewData = AddItemView.ViewData(
            placeholderText: "ADD_ITEM_PLACEHOLDER".localized,
            subtitle: Self.placeholderAttributedText,
            isAnimating: false
        )
        let addItemView = AddItemView(viewData: viewData, delegate: presenter as? AddItemViewDelegate)
        return addItemView
    }()

    private static var placeholderAttributedText: NSAttributedString {
        let text = "ADD_ITEM_SUBTITLE".localized
        let linkText = "ADD_ITEM_SUBTITLE_UNDERLINED".localized
        let attributedText = NSMutableAttributedString(string: text)

        let nsText = text as NSString
        let nsRange = nsText.range(of: linkText)
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        attributedText.addAttributes(attributes, range: nsRange)

        return attributedText
    }

    // MARK: - Styling

    private struct Constants {
        struct SaveItem {
            static let font = UIFont.systemFont(ofSize: 17, weight: .bold)
        }

        struct Alert {
            static let tintColor = UIColor.counters.accent
        }
    }

    // MARK: - Initialization

    init(presenter: AddItemPresenter, sourcePresenter: MainPresenter) {
        self.presenter = presenter
        self.sourcePresenter = sourcePresenter
        super.init(nibName: nil, bundle: nil)
        self.presenter.viewController = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - View controller lifecycle

    override func loadView() {
        view = addItemView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.counters.background
    }

    // MARK: TopBarProvider

    var topBarTitle: String? {
        "CREATE_A_COUNTER".localized
    }

    var topBarBackButtonText: String? {
        "CREATE_A_COUNTER_BACK_BUTTON".localized
    }

    var topBarLeftItems: [UIBarButtonItem]? = [
        UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelItem))
    ]

    var topBarRightItems: [UIBarButtonItem]? {
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSaveItem))
        let fontAttributes: [NSAttributedString.Key: Any] = [
            .font: Constants.SaveItem.font
        ]

        saveItem.setTitleTextAttributes(fontAttributes, for: .normal)
        saveItem.isEnabled = !presenter.isNetworkOperationInProgress

        return [saveItem]
    }

    var topBarPrefersLargeTitles: Bool { false }

    // MARK: - Top Bar actions

    @objc
    private func didTapCancelItem() {
        addItemView.resignFirstResponder()
        presenter.cancelItemCreation()
    }

    @objc
    private func didTapSaveItem() {
        let itemName = addItemView.text
        presenter.saveItem(name: itemName)
    }

    // MARK: - Alerts

    private func showAlert(
        title: String,
        message: String,
        buttonTitle: String,
        action: ((UIAlertAction) -> Void)?
    ) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alertController.addAction(
            UIAlertAction(
                title: buttonTitle,
                style: .cancel,
                handler: { actionHandler in
                    DispatchQueue.main.async {
                        action?(actionHandler)
                    }
                }
            )
        )

        alertController.view.tintColor = Constants.Alert.tintColor
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
}

extension AddItemViewController: AddItemViewDisplay {
    var mainNavigationController: MainNavigationController? { navigationController as? MainNavigationController }

    var isSaving: Bool {
        set {
            if newValue {
                addItemView.startAnimating()
            } else {
                addItemView.stopAnimating()
            }
        }

        get { addItemView.isAnimating }
    }

    func setTextFieldError() {
        addItemView.hasError = true
    }

    func showSavingError() {
        DispatchQueue.main.async {
            self.showAlert(
                title: "ADD_ITEM_ERROR_SAVING_TITLE".localized,
                message: "ADD_ITEM_ERROR_SAVING_MESSAGE".localized,
                buttonTitle: "ADD_ITEM_ERROR_SAVING_DISMISS_BUTTON".localized
            ) { action in
                self.addItemView.stopAnimating()
            }
        }
    }

    func showSavingSuccess() {
        let format = "ADD_ITEM_SUCCESS_SAVING_MESSAGE".localized

        /// I would have preferred to have the async in showAlert(), but
        /// since addItemView.text needs to be run on the main queue, I
        /// had to leave it here.
        DispatchQueue.main.async {
            let message = String(format: format, self.addItemView.text)

            self.showAlert(
                title: "ADD_ITEM_SUCCESS_SAVING_TITLE".localized,
                message: message,
                buttonTitle: "ADD_ITEM_SUCCESS_SAVING_DISMISS_BUTTON".localized
            ) { action in
                self.addItemView.stopAnimating()
                self.routeToMain(didCreateItem: true)
            }
        }
    }

    // TODO: Move these methods to a router/coordinator object (later).
    func routeToExamples() {
        let viewController = AddItemExamplesViewController(
            tableViewDataSource: AddItemExamplesTableViewDataSource(),
            tableViewDelegate: AddItemExamplesTableViewDelegate(),
            delegate: self
        )
        navigationController?.pushViewController(viewController, animated: true)
    }

    func routeToMain(didCreateItem: Bool = false) {
        sourcePresenter.addItemDidFinish(self, didCreateItem: didCreateItem)
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension AddItemViewController: AddItemExamplesDelegate {
    func userDidChooseExample(title: String) {
        addItemView.viewData = AddItemView.ViewData(
            text: title,
            placeholderText: "ADD_ITEM_PLACEHOLDER".localized,
            subtitle: Self.placeholderAttributedText,
            isAnimating: false
        )
        navigationController?.popViewController(animated: true)
    }
}
