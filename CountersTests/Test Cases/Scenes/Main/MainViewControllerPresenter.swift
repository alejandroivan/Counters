import Foundation
import XCTest
@testable import Counters

final class MainViewControllerPresenterTests: XCTestCase {

    private var sut: MainPresenter!
    private var useCase: MainViewControllerUseCase!
    private var dataSource: MainTableViewDataSource!
    private var delegate: MainTableViewDelegate!
    private var viewController: MainViewDisplayMock!
    private var mockNetworking: NetworkingMock!

    override func setUp() {
        super.setUp()
        mockNetworking = NetworkingMock()
        useCase = MainViewControllerUseCase(
            networking: SwiftNetworking(networking: mockNetworking),
            localCache: ItemsLocalCacheMock(),
            diffCache: DiffLocalCacheMock()
        )

        dataSource = MainTableViewDataSource()
        delegate = MainTableViewDelegate()

        sut = MainViewControllerPresenter(
            tableViewDataSource: dataSource,
            tableViewDelegate: delegate,
            useCase: useCase
        )
        
        viewController = MainViewDisplayMock()
        sut.viewController = viewController
        dataSource.presenter = sut
        delegate.presenter = sut
    }

    override func tearDown() {
        viewController = nil
        sut = nil
        delegate = nil
        dataSource = nil
        useCase = nil
        mockNetworking = nil
        super.tearDown()
    }

    // MARK: - isFiltering

    func testIsFiltering_valueEqualsViewControllerValue() {
        viewController.isFiltering = true
        XCTAssertEqual(sut.isFiltering, viewController.isFiltering)

        viewController.isFiltering = false
        XCTAssertEqual(sut.isFiltering, viewController.isFiltering)
    }

    func testIsFiltering_shouldReturnFalseIfViewControllerIsNil() {
        sut.viewController = nil
        XCTAssertEqual(sut.isFiltering, false)
    }

    // MARK: - filteredItems

    func testFilteredItems_valueEqualsViewControllerValue() {
        viewController.filteredItems = [Item(identifier: "a", title: "a", count: 1)]
        XCTAssertEqual(sut.filteredItems, viewController.filteredItems)

        viewController.filteredItems = []
        XCTAssertEqual(sut.filteredItems, viewController.filteredItems)
    }

    func testFilteredItems_shouldReturnEmptyIfViewControllerIsNil() {
        sut.viewController = nil
        XCTAssertEqual(sut.filteredItems, [])
    }

    // MARK: - isLoading

    func testViewDidLoad_shouldStartFetchingItems() {
        sut.viewDidLoad()
        XCTAssertTrue(mockNetworking.getUrlCalled)
    }

    // MARK: - updateBottomBarButtonsState()

    func testUpdateBottomBarButtonsState_shouldRefreshInTheViewController() {
        sut.updateBottomBarButtonsState()
        XCTAssertTrue(viewController.refreshBottomBarButtonsIfNeededCalled)
    }

    // MARK: - editItems()

    func testEditItems_shouldSetEditingInTheViewController() {
        viewController.isEditingItems = false
        sut.editItems()
        XCTAssertTrue(viewController.setEditingEnabledCalled)
        XCTAssertEqual(viewController.isEditingItems, true)
    }
}
