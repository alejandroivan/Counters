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
    private weak var errorView: MainErrorView?

    private enum ErrorKind {
        case noItems
        case noConnection
    }

    private var errorKind: ErrorKind?

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
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
        tableView.dataSource = presenter.tableViewDataSource
        tableView.delegate = presenter.tableViewDelegate
        presenter.tableViewDelegate.tableView = tableView

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
        guard errorView == nil else { return }
        
        let viewData = MainErrorView.ViewData(
            title: "MAIN_VIEW_ERROR_NOCOUNTERS_TITLE".localized,
            subtitle: "MAIN_VIEW_ERROR_NOCOUNTERS_SUBTITLE".localized,
            buttonTitle: "MAIN_VIEW_ERROR_NOCOUNTERS_BUTTON_TITLE".localized
        )
        let errorView = MainErrorView(viewData: viewData, delegate: self)

        view.addSubview(errorView)
        view.bringSubviewToFront(errorView)

        self.errorView = errorView
        errorKind = .noItems

        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func displayNoNetworkError() {
        print("ERROR: No network!")
    }

    // MARK: - Routing

    // TODO: Delegate this to a router/coordinator object (later).
    func routeToAddItem() {
        errorKind = nil
        errorView?.removeFromSuperview()

        let presenter = AddItemViewControllerPresenter(
            useCase: AddItemViewControllerUseCase(
                networking: SwiftNetworking()
            )
        )
        let viewController = AddItemViewController(presenter: presenter)
        let navigationController = MainNavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
}

// MARK: - ErrorViewDelegate

extension MainViewController: ErrorViewDelegate {

    func didPressActionButton() {
        let kind = errorKind

        switch kind {
        case .noItems:
            presenter.addItem()
        case .noConnection:
            presenter.fetchAllItems()
        case .none:
            break
        }
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

        let localized = items.count == 1 ? "ITEMS_COUNT".localized : "ITEMS_COUNT".pluralized
        let totalCount = items.reduce(0) { (result, item) -> Int in result + item.count }
        let finalString = String(format: localized, items.count, totalCount)

        return finalString
    }

    var bottomBarRightItems: [UIBarButtonItem]? {
        [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddItemButton(_:)))
        ]
    }
}
