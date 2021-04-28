import Foundation

protocol AddItemPresenter: class {

    var viewController: AddItemViewDisplay? { get set }

    var isNetworkOperationInProgress: Bool { get }

    func saveItem(name: String)
    func cancelItemCreation()
}
