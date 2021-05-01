import UIKit

/*
 NOTE: Since the use case layer has a local cache (diffCache) to know which items
 couldn't be synced with the backend (to do that later), we just don't need the
 "delete error" screen from Figma, as we added a synchronization "delete" case.
 */

final class MainViewController: UIViewController {

    var items: Items { presenter.items }

    private let presenter: MainPresenter

    private struct Constants {
        static let backgroundColor = UIColor.counters.background
        static let navigationBarMode: UINavigationItem.LargeTitleDisplayMode = .always

        struct SearchController {
            static let noResultsText = "MAIN_VIEW_SEARCH_BAR_NO_RESULTS".localized
            static let noResultsTextColor = UIColor.counters.secondaryText
            static let noResultsTextAlignment: NSTextAlignment = .center
            static let noResultsFont = UIFont.systemFont(ofSize: 20, weight: .regular)
            static var noResultsTopSpacing: CGFloat {
                let percentage: CGFloat = 0.36 // 36% screen height, tested to work fine on the iPhone 7 and the 12 Pro Max
                let topSpacing: CGFloat = UIScreen.main.bounds.size.height * percentage
                return topSpacing
            }
        }

        struct RefreshControl {
            static let color = UIColor.counters.primaryText
            // Defines if the refreshControl should appear on top of the navigation bar title
            // or below of it (old behavior, attached to the tableview top).
            static let appearsOnTop = false
            static let scaleFactor: CGFloat = 0.75
        }

        struct ActivityIndicator {
            /// There should be another ColorName for the ActivityIndicator,
            /// but I don't want to keep modifying that. So I'll use `.primaryText`,
            /// although this should be called `.primaryBlack` or similar.
            static let color = UIColor.counters.primaryText
            static let style: UIActivityIndicatorView.Style = .large
        }

        struct BottomBarItemStyle {
            static let add: UIBarButtonItem.SystemItem = .add
            static let delete: UIBarButtonItem.SystemItem = .trash
            static let share: UIBarButtonItem.SystemItem = .action
        }
    }

    // MARK: - Views

    private weak var mainNavigationController: MainNavigationController? { navigationController as? MainNavigationController }

    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: Constants.ActivityIndicator.style)

    private lazy var searchController = UISearchController(searchResultsController: nil)
    private weak var noResultsLabel: UILabel?

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Constants.RefreshControl.color
        refreshControl.transform = CGAffineTransform(
            scaleX: Constants.RefreshControl.scaleFactor,
            y: Constants.RefreshControl.scaleFactor
        )
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        return refreshControl
    }()

    private weak var errorView: MainErrorView?

    // MARK: - Private

    // MARK: UISearchResultsUpdating helpers

    var filteredItems: Items = [] {
        didSet {
            mainNavigationController?.updateBars(for: self)
            tableView.reloadData()
        }
    }

    var isSearchBarEmpty: Bool { searchController.searchBar.text?.isEmpty ?? true }

    var isFiltering: Bool { !isSearchBarEmpty }

    // MARK: Error kind

    private enum ErrorKind {
        case noItems
        case noConnection
    }

    private var errorKind: ErrorKind?

    // MARK: - Bottom Bar items

    /// This property needs to be lazy, in order to be evaluated after initialization.
    /// This is because, if declared as `private let`, it will be available at init,
    /// but the `didTapDeleteItemsButton()` selector is not (yet) evaluated at runtime,
    /// so the button will not call it. The marvels of Objective-C runtime 🎉
    private lazy var deleteBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: Constants.BottomBarItemStyle.delete, target: self, action: #selector(didTapDeleteItemsButton))
    }()

    /// The same as above applies to the `shareBarButtonItem`.
    private lazy var shareBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: Constants.BottomBarItemStyle.share, target: self, action: #selector(didTapShareItemsButton))
    }()

    /// And the same applies for this one.
    private lazy var addBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: Constants.BottomBarItemStyle.add, target: self, action: #selector(didTapAddItemButton(_:)))
    }()

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
        configureView()
        presenter.viewDidLoad()
    }

    private func configureView() {
        view.backgroundColor = Constants.backgroundColor
        /// This line is necessary for the UIRefreshControl to show correctly.
        extendedLayoutIncludesOpaqueBars = true
        definesPresentationContext = true
        navigationItem.largeTitleDisplayMode = Constants.navigationBarMode

        configureTableView()
        configureActivityIndicator()
        configureSearchController()
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.backgroundColor = Constants.backgroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.dataSource = presenter.tableViewDataSource
        tableView.delegate = presenter.tableViewDelegate

        if Constants.RefreshControl.appearsOnTop {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }

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

    private func configureSearchController() {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "MAIN_VIEW_SEARCH_BAR_PLACEHOLDER".localized
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
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

    // MARK: Edit items

    @objc
    private func didFinishEditingItems() {
        setEditingEnabled(false)
        mainNavigationController?.updateBars(for: self)
    }

    @objc
    private func didTapDeleteItemsButton() {
        let selectedItemCount = tableView.indexPathsForSelectedRows?.count ?? 0
        guard selectedItemCount > 0 else { return }

        let alertBase = "EDIT_ITEMS_DELETE_COUNTER"
        let alertFormat = selectedItemCount > 1 ? alertBase.pluralized : alertBase.localized
        let actionTitle = String(format: alertFormat, selectedItemCount)

        showAlert(
            title: nil,
            message: nil,
            actionTitle: actionTitle,
            style: .actionSheet,
            actionType: .destructive,
            action: { action in
                self.deleteItems()
            }
        )
    }

    @objc
    private func didTapShareItemsButton() {
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else { return }

        let itemsToShare = selectedIndexPaths.compactMap {
            self.items[$0.row]
        }

        let shareStrings = itemsToShare.compactMap { "\($0.count) × \($0.title)" }
        presenter.shareStrings(shareStrings)
    }

    private func deleteItems() {
        let itemsToRemove = tableView.indexPathsForSelectedRows?.compactMap {
            items[$0.row]
        } ?? []
        presenter.removeItems(itemsToRemove)
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
        indexPaths.compactMap { $0 }.forEach {
            let isAlreadySelected = tableView.cellForRow(at: $0)?.isSelected ?? false

            if !isAlreadySelected {
                tableView.selectRow(at: $0, animated: true, scrollPosition: .none)
                tableView.delegate?.tableView?(tableView, didSelectRowAt: $0)
            }
        }
        tableView.endUpdates()
    }

    @objc
    private func deselectAllItems() {
        var indexPaths: [IndexPath?] = []

        for item in items {
            guard let index = items.firstIndex(of: item) else { continue }
            let indexPath = IndexPath(row: index, section: 0)
            indexPaths.append(indexPath)
        }

        tableView.beginUpdates()
        indexPaths.compactMap { $0 }.forEach {
            let isSelected = tableView.cellForRow(at: $0)?.isSelected ?? false

            if isSelected {
                tableView.deselectRow(at: $0, animated: true)
                tableView.delegate?.tableView?(tableView, didDeselectRowAt: $0)
            }
        }
        tableView.endUpdates()
    }

    @objc
    func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        presenter.fetchAllItems()
    }
}

// MARK: - MainViewDisplay protocol

extension MainViewController: MainViewDisplay {

    func refreshBottomBarButtonsIfNeeded() {
        let areEnabled = (tableView.indexPathsForSelectedRows?.count ?? 0) > 0
        deleteBarButtonItem.isEnabled = areEnabled
        shareBarButtonItem.isEnabled = areEnabled
    }

    // MARK: Data

    func displayItems() {
        setEditingEnabled(false)
        updateFilteredItems()
        tableView.reloadData()
        mainNavigationController?.updateBars(for: self)
        self.refreshControl.endRefreshing()
    }

    func displayEmptyError() {
        if errorView != nil {
            hideErrors()
        }
        
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
        if errorView != nil {
            hideErrors()
        }

        let viewData = MainErrorView.ViewData(
            title: "MAIN_VIEW_ERROR_NOCONNECTION_TITLE".localized,
            subtitle: "MAIN_VIEW_ERROR_NOCONNECTION_SUBTITLE".localized,
            buttonTitle: "MAIN_VIEW_ERROR_NOCONNECTION_BUTTON_TITLE".localized
        )
        let errorView = MainErrorView(viewData: viewData, delegate: self)

        view.addSubview(errorView)
        view.bringSubviewToFront(errorView)

        self.errorView = errorView
        errorKind = .noConnection

        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func hideErrors() {
        errorView?.removeFromSuperview()
        errorKind = nil
    }

    // MARK: Activity

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

    // MARK: Routing

    /// This could have been done in a coordinator/router object.
    /// For simplifying this "architecture", I'm going to say:
    /// "The views handle navigation, based on: Clean Swift."
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
        present(navigationController, animated: true)
    }

    // MARK: Editing

    func setEditingEnabled(_ isEditing: Bool) {
        tableView.allowsMultipleSelection = isEditing
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(isEditing, animated: true)
        mainNavigationController?.updateBars(for: self)
    }

    var isEditingItems: Bool { tableView.isEditing }

    // MARK: Filtering

    func updateFilteredItems() {
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        filteredItems = items.filter { $0.title.lowercased().contains(text) }

        if filteredItems.isEmpty, isFiltering {
            showNoResultsMessage()
        } else {
            hideNoResultsMessage()
        }
    }

    private func showNoResultsMessage() {
        guard noResultsLabel == nil else { return }

        let label = UILabel()
        noResultsLabel = label
        view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.SearchController.noResultsText
        label.textColor = Constants.SearchController.noResultsTextColor
        label.font = Constants.SearchController.noResultsFont
        label.textAlignment = Constants.SearchController.noResultsTextAlignment

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.SearchController.noResultsTopSpacing),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func hideNoResultsMessage() {
        noResultsLabel?.removeFromSuperview()
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

// MARK: Top Bar

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
                    title: "EDIT_ITEMS_SELECT_NONE".localized,
                    style: .plain,
                    target: self,
                    action: #selector(deselectAllItems)
                ),
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

// MARK: Bottom Bar

extension MainViewController: BottomBarProvider {
    var showsBottomBar: Bool { true }

    var bottomBarLeftItems: [UIBarButtonItem]? {
        guard !isFiltering, tableView.isEditing else { return nil }
        refreshBottomBarButtonsIfNeeded()
        return [deleteBarButtonItem]
    }

    var bottomBarCenterText: String? {
        let items = isFiltering ? filteredItems : self.items
        guard !items.isEmpty else { return nil }

        let localized = items.count == 1 ? "ITEMS_COUNT".localized : "ITEMS_COUNT".pluralized
        let totalCount = items.reduce(0) { (result, item) -> Int in return result + item.count }
        let finalString = String(format: localized, items.count, totalCount)

        return finalString
    }

    var bottomBarRightItems: [UIBarButtonItem]? {
        guard !isFiltering else { return nil }
        
        if tableView.isEditing {
            return [shareBarButtonItem]
        } else {
            return [addBarButtonItem]
        }
    }
}

// MARK: - UISearchController

extension MainViewController: UISearchControllerDelegate {

    func willPresentSearchController(_ searchController: UISearchController) {
        setEditingEnabled(false)
    }
}

extension MainViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        updateFilteredItems()
    }
}
