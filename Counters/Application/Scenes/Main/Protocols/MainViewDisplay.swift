import Foundation

protocol MainViewDisplay: class {
    // MARK: - Data
    func displayItems()

    // MARK: - Routing
    func routeToAddItem()
}
