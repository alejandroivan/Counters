import Foundation

protocol MainPresenter: class {

    var viewController: MainViewDisplay? { get set }
    var dataSource: MainTableViewDataSource { get }

    var items: Items { get }

    /// Must be called at the end of viewDidLoad() in the view controller.
    /// Basically starts whatever the presenter needs to do at initialization,
    /// but delayed to when the view has loaded.
    func viewDidLoad()

    // MARK: - Edit button

    func editItems()

    // MARK: - Add item button

    func addItem()
}
