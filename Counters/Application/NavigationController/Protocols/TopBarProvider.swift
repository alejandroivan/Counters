import UIKit

public protocol TopBarProvider where Self: UIViewController {

    /// Defines the title to be shown in the navigation bar for this view controller.
    var topBarTitle: String? { get }

    /// Defines the text to be shown in a navigation bar "back button" that
    /// will route back to the current view controller.
    var topBarBackButtonText: String? { get }

    /// Defines the left bar button items to be shown when this view controller is presented.
    /// These items won't be shown if a back button is currently visible.
    var topBarLeftItems: [UIBarButtonItem]? { get }

    /// Defines the right bar button items to be shown when this view controller is presented.
    /// Right items are added from right to left, so the first in the list will appear the right most.
    var topBarRightItems: [UIBarButtonItem]? { get }

    /// Defines either the top bar should use large titles or not.
    /// Defaults to true.
    var topBarPrefersLargeTitles: Bool { get }
}

extension TopBarProvider {
    var topBarPrefersLargeTitles: Bool { true }
}
