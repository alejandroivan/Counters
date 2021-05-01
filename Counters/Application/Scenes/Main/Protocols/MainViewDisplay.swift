import Foundation

protocol MainViewDisplay: class {

    // MARK: - Data
    func displayItems()
    func displayEmptyError()
    func displayNoNetworkError()
    func hideErrors()

    // MARK: - Activity
    func showActivityIndicator()
    func hideActivityIndicator()

    // MARK: - Routing
    func routeToAddItem()

    // MARK: - Editing
    func setEditingEnabled(_ isEditing: Bool)
    var isEditingItems: Bool { get }
    func refreshBottomBarButtonsIfNeeded()

    // MARK: - Search bar

    var filteredItems: Items { get }
    var isFiltering: Bool { get }
    func updateFilteredItems()
}
