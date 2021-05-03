import Foundation
import UIKit
import XCTest
@testable import Counters

final class MainTableViewDelegateTests: XCTestCase {

    private var sut: MainTableViewDelegate!
    private var dataSource: MainTableViewDataSource!
    private var useCase: MainViewControllerUseCase!
    private var presenter: MainViewControllerPresenter!
    private var viewController: MainViewDisplayMock!
    private var tableView: UITableView { viewController.tableView }

    override func setUp() {
        super.setUp()
        sut = MainTableViewDelegate()
        dataSource = MainTableViewDataSource()
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
            tableViewDataSource: dataSource,
            tableViewDelegate: sut,
            useCase: useCase
        )
        viewController = MainViewDisplayMock()

        dataSource.presenter = presenter
        sut.presenter = presenter

        presenter.viewController = viewController
        sut.tableView = tableView

        tableView.dataSource = dataSource
        tableView.delegate = sut

        tableView.registerReusable(MainViewItemCell.self)
    }

    override func tearDown() {
        tableView.removeFromSuperview()
        viewController = nil
        presenter = nil
        useCase = nil
        dataSource = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Cell height

    func testHeightForRow_shouldBeAutomaticDimension() {
        let indexPath = IndexPath(row: 0, section: 0)

        let estimatedHeight = sut.tableView(tableView, estimatedHeightForRowAt: indexPath)
        let height = sut.tableView(tableView, heightForRowAt: indexPath)

        XCTAssertEqual(estimatedHeight, UITableView.automaticDimension)
        XCTAssertEqual(height, UITableView.automaticDimension)
    }

    // MARK: - didSelectRow

    func testDidSelectRow_updatesBottomBarButtonsState_whenTableViewIsEditing() {
        tableView.isEditing = true
        sut.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(viewController.refreshBottomBarButtonsIfNeededCalled)
    }

    func testDidSelectRow_shouldDoNothing_whenTableViewIsNotEditing() {
        tableView.isEditing = false
        sut.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertFalse(viewController.refreshBottomBarButtonsIfNeededCalled)
    }

    // MARK: - didDeselectRow

    func testDidDeselectRow_updatesBottomBarButtonsState_whenTableViewIsEditing() {
        tableView.isEditing = true
        sut.tableView(tableView, didDeselectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(viewController.refreshBottomBarButtonsIfNeededCalled)
    }

    func testDidDeselectRow_shouldDoNothing_whenTableViewIsNotEditing() {
        tableView.isEditing = false
        sut.tableView(tableView, didDeselectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertFalse(viewController.refreshBottomBarButtonsIfNeededCalled)
    }

    // MARK: - MainViewItemCellDelegate

    func testCountAction_shouldIncrementItem_withIncrementParameter() {
        presenter.viewDidLoad() // forces the presenter to load some items from the mocks
        let indexPath = IndexPath(row: 0, section: 0)
        let parameter: MainViewItemAction = .increment
        sut.mainViewCell(indexPath, countAction: parameter)
        XCTAssertTrue(viewController.displayItemsCalled)
    }

    func testCountAction_shouldIncrementItem_withDecrementParameter() {
        presenter.viewDidLoad() // forces the presenter to load some items from the mocks
        let indexPath = IndexPath(row: 0, section: 0)
        let parameter: MainViewItemAction = .decrement
        sut.mainViewCell(indexPath, countAction: parameter)
        XCTAssertTrue(viewController.displayItemsCalled)
    }

    func testCountAction_shouldIncrementItem_withIncrementParameterAndFiltering() {
        presenter.viewDidLoad() // forces the presenter to load some items from the mocks
        viewController.isFiltering = true
        let indexPath = IndexPath(row: 0, section: 0)
        let parameter: MainViewItemAction = .increment
        sut.mainViewCell(indexPath, countAction: parameter)
        XCTAssertTrue(viewController.displayItemsCalled)
    }
}
