import Foundation
import XCTest
@testable import Counters

final class MainNavigationControllerTests: XCTestCase {

    private var containedViewController: BarProviderMock!
    private var sut: MainNavigationController!

    override func setUp() {
        super.setUp()
        containedViewController = BarProviderMock()
        sut = MainNavigationController(rootViewController: containedViewController as BarProvider)
    }

    override func tearDown() {
        sut = nil
        containedViewController = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func testInitialization_asTopBarProvider() {
        sut = MainNavigationController(
            rootViewController: containedViewController as TopBarProvider
        )
        XCTAssertNotNil(sut)
    }

    func testInitialization_asBottomBarProvider() {
        sut = MainNavigationController(
            rootViewController: containedViewController as BottomBarProvider
        )
        XCTAssertNotNil(sut)
    }

    func testInitialization_withCoder() {
        let object = MainNavigationController(rootViewController: BarProviderMock())

        guard
            let data = try? NSKeyedArchiver.archivedData(
                withRootObject: object,
                requiringSecureCoding: false
            ),
            let coder = try? NSKeyedUnarchiver(forReadingFrom: data)
        else {
            XCTFail("Cannot decode view controller.")
            return
        }

        sut = MainNavigationController(coder: coder)
        XCTAssertNotNil(sut)
    }

    // MARK: - Styling

    func testUpdateBars_setsValuesFromProviders() {
        let viewController = sut.viewControllers.first!
        let navigationBar = sut.navigationBar
        let navigationItem = viewController.navigationItem
        let toolbar = sut.toolbar!
        let barProvider = BarProviderMock()

        sut.updateBars(for: viewController)

        // TopBarProvider
        XCTAssertEqual(barProvider.topBarTitle, navigationItem.title)
        XCTAssertEqual(barProvider.topBarBackButtonText, navigationItem.backButtonTitle)
        XCTAssertEqual(barProvider.topBarLeftItems?.count, navigationItem.leftBarButtonItems?.count)
        XCTAssertEqual(barProvider.topBarRightItems?.count, navigationItem.rightBarButtonItems?.count)
        XCTAssertEqual(barProvider.topBarPrefersLargeTitles, navigationBar.prefersLargeTitles)

        // BottomBarProvider
        let leftItemsCount = barProvider.bottomBarLeftItems?.count ?? 0
        let centerItemsCount = 2 + 1 // 2 spacers + 1 center text
        let rightItemsCount = barProvider.bottomBarRightItems?.count ?? 0
        let totalCount = leftItemsCount + centerItemsCount + rightItemsCount

        XCTAssertNotEqual(barProvider.showsBottomBar, toolbar.isHidden)
        XCTAssertEqual(totalCount, viewController.toolbarItems?.count ?? 0)
    }

    func testDelegate_shouldBeItself() {
        let sutDelegate = sut.delegate
        XCTAssertTrue(sut === sutDelegate) // Pointer comparison, they should be the same object
    }

    func testWillShowViewController_callsUpdateBars() {
        let viewController = BarProviderMock()
        let sutDelegate = sut.delegate

        sutDelegate?.navigationController?(sut, willShow: viewController, animated: true)

        XCTAssertNotNil(sutDelegate)
        XCTAssertEqual(viewController.topBarTitle, viewController.navigationItem.title)
    }
}
