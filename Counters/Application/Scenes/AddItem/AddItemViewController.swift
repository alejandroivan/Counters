import UIKit

final class AddItemViewController: UIViewController {

    private let presenter: AddItemPresenter

    private lazy var addItemView: AddItemView = {
        let viewData = AddItemView.ViewData(
            placeholderText: "ADD_ITEM_PLACEHOLDER".localized,
            subtitle: Self.placeholderAttributedText,
            isAnimating: true
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
    }

    // MARK: - Initialization

    init(presenter: AddItemPresenter) {
        self.presenter = presenter
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

    // MARK: - Top Bar actions

    @objc
    private func didTapCancelItem() {
        presenter.cancelItemCreation()
    }

    @objc
    private func didTapSaveItem() {
        presenter.saveItem()
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

    func routeToExamples() {
        let dataSource = AddItemExamplesTableViewDataSource()
        let viewController = AddItemExamplesViewController(dataSource: dataSource)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: Top/Bottom Bars

extension AddItemViewController: TopBarProvider {
    var topBarTitle: String? {
        "CREATE_A_COUNTER".localized
    }

    var topBarBackButtonText: String? {
        "Create"
    }

    var topBarLeftItems: [UIBarButtonItem]? {
        [
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelItem))
        ]
    }

    var topBarRightItems: [UIBarButtonItem]? {
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSaveItem))
        let fontAttributes: [NSAttributedString.Key: Any] = [
            .font: Constants.SaveItem.font
        ]
        
        saveItem.setTitleTextAttributes(fontAttributes, for: .normal)
        saveItem.isEnabled = !presenter.isNetworkOperationInProgress

        return [
            saveItem
        ]
    }

    var topBarPrefersLargeTitles: Bool { false }
}
