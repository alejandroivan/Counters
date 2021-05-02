import Foundation
import UIKit
import XCTest
@testable import Counters

final class MainTableViewDataSourceTests: XCTestCase {

    private var sut: MainTableViewDataSource!
    private var delegate: MainTableViewDelegate!
    private var useCase: MainViewControllerUseCase!
    private var presenter: MainViewControllerPresenter!
    private var viewController: MainViewDisplayMock!
    private let tableView = UITableView()

    override func setUp() {
        super.setUp()
        sut = MainTableViewDataSource()
        delegate = MainTableViewDelegate()
        useCase = MainViewControllerUseCase(
            networking: SwiftNetworking(
                networking: NetworkingMock(),
                reachability: SwiftReachability(
                    reachability: ReachabilityMock()
                )
            ),
            localCache: ItemsLocalCacheMock(),
            diffCache: DiffLocalCacheMock()
        )
        presenter = MainViewControllerPresenter(
            tableViewDataSource: sut,
            tableViewDelegate: delegate,
            useCase: useCase
        )
        viewController = MainViewDisplayMock()

        sut.presenter = presenter
        presenter.viewController = viewController
        tableView.dataSource = sut
        tableView.delegate = delegate

        tableView.registerReusable(MainViewItemCell.self)
    }

    override func tearDown() {
        viewController = nil
        presenter = nil
        useCase = nil
        delegate = nil
        sut = nil
        super.tearDown()
    }

    func testSetConnections_onInit() {
        XCTAssertNotNil(sut.presenter)
    }

    func testNumberOfSections() {
        let numberOfSections = sut.numberOfSections(in: tableView)
        XCTAssertEqual(numberOfSections, 1)
    }

    func testNumberOfRows_whenNotFiltering() {
        let numberOfRows = sut.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(numberOfRows, presenter.items.count)
    }

    func testNumberOfRows_whenFiltering() {
        viewController.isFiltering = true
        let numberOfItems = sut.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(numberOfItems, presenter.filteredItems.count)
        XCTAssertNotEqual(presenter.items.count, presenter.filteredItems.count)
    }

    func testCellForRow_isOfCorrectTypeAndHasPropertiesSet() {
        viewController.isFiltering = true // We make sure we get at least one item
        let genericCell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        let cell = genericCell as? MainViewItemCell

        // We make sure it's not nil when casted, equals to `genericCell is MainViewItemCell`
        XCTAssertNotNil(cell)

        XCTAssertNotNil(cell?.viewData)
        XCTAssertNotNil(cell?.delegate)
    }
}
