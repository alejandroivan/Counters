import Foundation
import UIKit
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

    func testRemoveItems_shouldUpdateTheViewController_onCompletion() {
        let item = Item(identifier: "a", title: "a", count: 1)
        let exp = expectation(description: "View controller gets updated on completion")

        sut.removeItems([item])

        DispatchQueue.main.async {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)

        XCTAssertTrue(viewController.showActivityIndicatorCalled)
        XCTAssertTrue(viewController.displayItemsCalled)
        XCTAssertTrue(viewController.hideActivityIndicatorCalled)
        XCTAssertGreaterThan(sut.items.count, 0)
    }

    func testRemoveItems_shouldDisplayEmptyError_onCompletion() {
        let item = Item(identifier: "a", title: "a", count: 1)
        let exp = expectation(description: "View controller should show empty list error if data is empty")
        mockNetworking.dataShouldBeEmpty = true

        sut.removeItems([item])

        DispatchQueue.main.async {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)

        XCTAssertTrue(viewController.showActivityIndicatorCalled)
        XCTAssertTrue(viewController.displayEmptyErrorCalled)
        XCTAssertTrue(viewController.hideActivityIndicatorCalled)
        XCTAssertEqual(sut.items.count, 0)
    }

    // MARK: - Add items

    func testAddItem_shouldRouteToAddItemView() {
        sut.addItem()
        XCTAssertTrue(viewController.routeToAddItemCalled)
    }

    func testAddItemDidFinishWithSuccess_shouldFetchAllItems_onDelegateCall() {
        sut.addItemDidFinish(nil, didCreateItem: true)
        XCTAssertTrue(mockNetworking.getUrlCalled)
    }

    // MARK: - Fetch items

    func testFetchAllItems_shouldHideErrors() {
        sut.fetchAllItems()
        XCTAssertTrue(viewController.hideErrorsCalled)
    }

    func testFetchAllItems_shouldShowNoNetworkError_onConnectionFailure() {
        mockNetworking.shouldFail = true
        let exp = expectation(description: "fetchAllItems() should display error when useCase.getItems fails")
        sut.fetchAllItems()

        DispatchQueue.main.async {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)

        XCTAssertTrue(viewController.displayNoNetworkErrorCalled)
    }

    func testFetchAllItems_shouldShowEmptyError_onEmptyItemList() {
        mockNetworking.dataShouldBeEmpty = true
        let exp = expectation(
            description: "fetchAllItems() should display error when useCase.getItems returns an empty list"
        )
        sut.fetchAllItems()

        DispatchQueue.main.async {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)

        XCTAssertTrue(viewController.displayEmptyErrorCalled)
    }

    // MARK: - Counting

    func testIncrementItem_shouldIncrementAndDisplayNewItemList() {
        sut.fetchAllItems() // Create a list of items from #api#v1#counters.json
        let count = sut.items.first!.count

        sut.incrementItem(at: 0)

        let newCount = sut.items.first!.count
        XCTAssertEqual(newCount, count + 1)
        XCTAssertTrue(viewController.displayItemsCalled)
    }

    func testDecrementItem_shouldDecrementAndDisplayNewItemList() {
        sut.fetchAllItems() // Create a list of items from #api#v1#counters.json
        let count = sut.items.first!.count

        sut.decrementItem(at: 0)

        let newCount = sut.items.first!.count
        XCTAssertEqual(newCount, count - 1)
        XCTAssertTrue(viewController.displayItemsCalled)
    }
}
