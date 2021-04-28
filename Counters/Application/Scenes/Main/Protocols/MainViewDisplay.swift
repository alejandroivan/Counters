import Foundation

protocol MainViewDisplay: class {

    // MARK: - Data
    func displayItems()
    func displayEmptyError()
    func displayNoNetworkError()

    // MARK: - Routing
    func routeToAddItem()
}
