import UIKit

final class AddItemViewController: UIViewController {

    private let presenter: AddItemPresenter

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
}

// MARK: Top/Bottom Bars

extension AddItemViewController: TopBarProvider {
    var topBarTitle: String? {
        "CREATE_A_COUNTER".localized
    }

    var topBarBackButtonText: String? {
        nil
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
