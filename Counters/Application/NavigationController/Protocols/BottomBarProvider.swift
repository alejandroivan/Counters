import UIKit

public protocol BottomBarProvider where Self: UIViewController {

    /// Defines either the toolbar (bottom bar) should be visible or not.
    var showsBottomBar: Bool { get }

    /// Defines the left items to be shown in the toolbar.
    var bottomBarLeftItems: [UIBarButtonItem]? { get }

    /// Defines the text to be shown in the center of the toolbar.
    var bottomBarCenterText: String? { get }

    /// Defines the right items to be shown in the toolbar.
    var bottomBarRightItems: [UIBarButtonItem]? { get }

    /// Passthrough for toolbarItems on a UIViewController.
    var toolbarItems: [UIBarButtonItem]? { get }
}
