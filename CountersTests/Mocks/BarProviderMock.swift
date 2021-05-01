@testable import Counters
import UIKit

final class BarProviderMock: UIViewController, BarProvider {

    // MARK: - TopBarProvider

    var topBarTitle: String? = "title"

    var topBarBackButtonText: String? = "back"

    var topBarLeftItems: [UIBarButtonItem]? = [
        UIBarButtonItem(systemItem: .close)
    ]

    var topBarRightItems: [UIBarButtonItem]? = [
        UIBarButtonItem(systemItem: .done)
    ]

    var topBarPrefersLargeTitles: Bool = false

    // MARK: - BottomBarProvider

    var showsBottomBar: Bool = true

    var bottomBarLeftItems: [UIBarButtonItem]? = [
        UIBarButtonItem(systemItem: .close)
    ]

    var bottomBarCenterText: String? = "center"

    var bottomBarRightItems: [UIBarButtonItem]? = [
        UIBarButtonItem(systemItem: .done)
    ]

    // `toolbarItems` is not needed, since it comes from `UIViewController`
}
