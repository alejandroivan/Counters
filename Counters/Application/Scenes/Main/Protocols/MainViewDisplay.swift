import Foundation

protocol MainViewDisplay: class {

    // MARK: - Data
    func displayItems()
    func displayEmptyError()
    func displayNoNetworkError()

    // MARK: - Activity
    func showActivityIndicator()
    func hideActivityIndicator()

    // MARK: - Routing
    func routeToAddItem()

    // MARK: - Editing
    func setEditingEnabled(_ isEditing: Bool)
    var isEditingItems: Bool { get }
}
