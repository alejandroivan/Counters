import Foundation

protocol MainPresenter: class {

    var viewController: MainViewDisplay? { get set }
    var tableViewDataSource: MainTableViewDataSource { get }
    var tableViewDelegate: MainTableViewDelegate { get }

    var items: Items { get set }

    /// Must be called at the end of viewDidLoad() in the view controller.
    /// Basically starts whatever the presenter needs to do at initialization,
    /// but delayed to when the view has loaded.
    func viewDidLoad()

    // MARK: - Edit button

    func editItems()

    // MARK: - Add item

    func addItem()
    func addItemDidFinish(_ addItemView: AddItemViewDisplay?)

    // MARK: - Fetch items

    func fetchAllItems()

    // MARK: - Counting

    func incrementItem(at index: Int)
    func decrementItem(at index: Int)
}
