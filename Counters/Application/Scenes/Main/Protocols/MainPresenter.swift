import Foundation

protocol MainPresenter: class {

    var viewController: MainViewDisplay? { get set }
    var tableViewDataSource: MainTableViewDataSource { get }
    var tableViewDelegate: MainTableViewDelegate { get }

    var items: Items { get }

    /// Must be called at the end of viewDidLoad() in the view controller.
    /// Basically starts whatever the presenter needs to do at initialization,
    /// but delayed to when the view has loaded.
    func viewDidLoad()
    func viewWillAppear()

    // MARK: - Edit button

    func editItems()

    // MARK: - Add item button

    func addItem()

    // MARK: - Fetch items

    func fetchAllItems()
}
