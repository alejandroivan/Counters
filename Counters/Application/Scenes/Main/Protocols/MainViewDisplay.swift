import Foundation

protocol MainViewDisplay: class {
    // MARK: - Data
    func displayItems()
    func displayEmptyError()

    // MARK: - Routing
    func routeToAddItem()
}
