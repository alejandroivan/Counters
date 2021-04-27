import UIKit

final class MainViewController: UIViewController {

    var items: Items { presenter.items }
    private let presenter: MainPresenter

    private struct Constants {
        static let backgroundColor = UIColor.counters.background
    }

    // MARK: - Views

    private weak var mainNavigationController: MainNavigationController? { navigationController as? MainNavigationController }

    private let tableView = UITableView()

    // MARK: - Initialization

    init(presenter: MainPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.presenter.viewController = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - View controller lifecycle & View setup

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        configureView()
        presenter.viewDidLoad()
    }

    private func configureView() {
        view.backgroundColor = Constants.backgroundColor
        configureTableView()
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = Constants.backgroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.dataSource = presenter.dataSource

        tableView.registerReusable(MainViewItemCell.self)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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

    // MARK: - Data

    func displayItems() {
        mainNavigationController?.updateBars()
        tableView.reloadData()
    }

    func displayEmptyError() {
        print("ERROR: Empty response!")
    }

    // MARK: - Routing

    // TODO: Delegate this to a router/coordinator object (later).
    func routeToAddItem() {
        let presenter = AddItemViewControllerPresenter()
        let viewController = AddItemViewController(presenter: presenter)
        let navigationController = MainNavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
}

// MARK: - Top/Bottom Bars

extension MainViewController: TopBarProvider {

    var topBarTitle: String? { "Counters" }

    var topBarBackButtonText: String? {
        nil
    }

    var topBarLeftItems: [UIBarButtonItem]? {
        let item = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEditButton))
        if items.isEmpty {
            item.isEnabled = false
        }
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
