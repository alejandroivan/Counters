@testable import Counters
import UIKit

final class MainViewDisplayMock: MainViewDisplay {

    var displayItemsCalled = false
    var displayEmptyErrorCalled = false
    var displayNoNetworkErrorCalled = false
    var hideErrorsCalled = false
    var showActivityIndicatorCalled = false
    var hideActivityIndicatorCalled = false
    var routeToAddItemCalled = false
    var setEditingEnabledCalled = false
    var refreshBottomBarButtonsIfNeededCalled = false
    var updateFilteresItemsCalled = false

    var isEditingItems = false
    var filteredItems: Items = []
    var isFiltering = false

    func displayItems() {
        displayItemsCalled = true
    }

    func displayEmptyError() {
        displayEmptyErrorCalled = true
    }

    func displayNoNetworkError() {
        displayNoNetworkErrorCalled = true
    }

    func hideErrors() {
        hideErrorsCalled = true
    }

    func showActivityIndicator() {
        showActivityIndicatorCalled = true
    }

    func hideActivityIndicator() {
        hideActivityIndicatorCalled = true
    }

    func routeToAddItem() {
        routeToAddItemCalled = true
    }

    func setEditingEnabled(_ isEditing: Bool) {
        setEditingEnabledCalled = true
        isEditingItems = isEditing
    }

    func refreshBottomBarButtonsIfNeeded() {
        refreshBottomBarButtonsIfNeededCalled = true
    }

    func updateFilteredItems() {
        updateFilteresItemsCalled = true
    }
}
