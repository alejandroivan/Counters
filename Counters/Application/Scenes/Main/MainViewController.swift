import UIKit

final class MainViewController: UIViewController {

    var items: Items = []
    private let presenter: MainViewPresenter

    // MARK: - Views

    private weak var mainNavigationController: MainNavigationController? { navigationController as? MainNavigationController }

    private let tableView = UITableView()

    // MARK: - Initialization

    init(presenter: MainViewPresenter) {
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
        presenter.viewDidLoad()
    }

    // MARK: - Buttons

    // MARK: Edit

    @objc
    private func didTapEditButton() {
        presenter.editItems()
    }

    // MARK: Add item

    @objc
    private func didTapAddItemButton(_ button: UIBarButtonItem) {
        presenter.addItem()
    }
}

// MARK: - MainViewDisplay protocol

extension MainViewController: MainViewDisplay {
    func presentItems(_ items: Items) {
        self.items = items
        tableView.reloadData()
        mainNavigationController?.updateBars()
    }
}

// MARK: - Top/Bottom Bars

extension MainViewController: TopBarProvider {

    var topBarTitle: String? { "Counters" }

    var topBarBackButtonText: String? {
        nil
    }

    var topBarLeftItems: [UIBarButtonItem]? {
        guard !items.isEmpty else { return nil }
        let item = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEditButton))
        return [item]
    }

    var topBarRightItems: [UIBarButtonItem]? { [] }
}

extension MainViewController: BottomBarProvider {
    var showsBottomBar: Bool { true }

    var bottomBarLeftItems: [UIBarButtonItem]? { [] }

    var bottomBarCenterText: String? {
        guard !items.isEmpty else { return nil }
        return "\(items.count) items"
    }

    var bottomBarRightItems: [UIBarButtonItem]? {
        [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddItemButton(_:)))
        ]
    }
}
