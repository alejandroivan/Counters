import UIKit

final class MainViewController: UIViewController {

    var items: Items { presenter.items }
    private let presenter: MainPresenter

    private struct Constants {
        static let backgroundColor = UIColor.counters.background

        struct ActivityIndicator {
            /// There should be another ColorName for the ActivityIndicator,
            /// but I don't want to keep modifying that. So I'll use `.primaryText`,
            /// although this should be called `.primaryBlack` or similar.
            static let color = UIColor.counters.primaryText
            static let style: UIActivityIndicatorView.Style = .large
        }
    }

    // MARK: - Views

    private weak var mainNavigationController: MainNavigationController? { navigationController as? MainNavigationController }

    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: Constants.ActivityIndicator.style)
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

    private func configureView() {
        view.backgroundColor = Constants.backgroundColor
        configureTableView()
        configureActivityIndicator()
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

    private func configureActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = Constants.ActivityIndicator.color
        activityIndicator.backgroundColor = view.backgroundColor
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

    // MARK: - Editing items

    @objc
    private func didFinishEditingItems() {
        setEditingEnabled(false)
        mainNavigationController?.updateBars(for: self)
    }

    @objc
    private func selectAllItems() {
        var indexPaths: [IndexPath?] = []

        for item in items {
            guard let index = items.firstIndex(of: item) else { continue }
            let indexPath = IndexPath(row: index, section: 0)
            indexPaths.append(indexPath)
        }

        tableView.beginUpdates()
        /// NOTE: Documentation about `UITableView.ScrollPosition` is wrong from Apple.
        /// This method does NOT scroll the selected row to visible, even though the docs say so.
        /// Link: https://developer.apple.com/documentation/uikit/uitableview/scrollposition
        indexPaths.forEach { tableView.selectRow(at: $0, animated: true, scrollPosition: .none)}
        tableView.endUpdates()
    }
}

// MARK: - MainViewDisplay protocol

extension MainViewController: MainViewDisplay {

    // MARK: - Data

    func displayItems() {
        mainNavigationController?.updateBars(for: self)
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

    // MARK: - Activity

    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }

    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }

    // MARK: - Routing

    // TODO: Delegate this to a router/coordinator object (later).
    func routeToAddItem() {
        let addItemPresenter = AddItemViewControllerPresenter(
            useCase: AddItemViewControllerUseCase(
                networking: SwiftNetworking()
            )
        )
        let viewController = AddItemViewController(
            presenter: addItemPresenter,
            sourcePresenter: presenter
        )
        let navigationController = MainNavigationController(rootViewController: viewController)
        present(navigationController, animated: true) {
            self.errorKind = nil
            self.errorView?.removeFromSuperview()
        }
    }

    // MARK: - Editing

    func setEditingEnabled(_ isEditing: Bool) {
        tableView.allowsMultipleSelection = isEditing
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(isEditing, animated: true)
        mainNavigationController?.updateBars(for: self)
    }

    var isEditingItems: Bool { tableView.isEditing }
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

    var topBarTitle: String? { "MAIN_VIEW_TITLE".localized }

    var topBarBackButtonText: String? {
        nil
    }

    var topBarLeftItems: [UIBarButtonItem]? {
        var leftItems: [UIBarButtonItem] = []

        if tableView.isEditing {
            leftItems = [
                UIBarButtonItem(
                    barButtonSystemItem: .done,
                    target: self,
                    action: #selector(didFinishEditingItems)
                )
            ]
        } else {
            let item = UIBarButtonItem(
                barButtonSystemItem: .edit,
                target: self,
                action: #selector(didTapEditButton)
            )

            if items.isEmpty {
                item.isEnabled = false
            }

            leftItems = [item]
        }

        return leftItems
    }

    var topBarRightItems: [UIBarButtonItem]? {
        var items: [UIBarButtonItem] = []

        if tableView.isEditing {
            items = [
                UIBarButtonItem(
                    title: "EDIT_ITEMS_SELECT_ALL".localized,
                    style: .plain,
                    target: self,
                    action: #selector(selectAllItems)
                )
            ]
        }

        return items
    }
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
