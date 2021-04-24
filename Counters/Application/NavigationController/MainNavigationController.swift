import UIKit

final class MainNavigationController: UINavigationController {

    typealias BarProvider = TopBarProvider & BottomBarProvider

    // MARK: - Initialization

    public init(rootViewController: BarProvider) {
        super.init(rootViewController: rootViewController)
        commonInit()
    }

    public init(rootViewController: TopBarProvider) {
        super.init(rootViewController: rootViewController)
        commonInit()
    }

    public init(rootViewController: BottomBarProvider) {
        super.init(rootViewController: rootViewController)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        delegate = self
        modalPresentationStyle = .fullScreen
        view.backgroundColor = UIColor.counters.background
        configureNavigationBar()
    }

    // MARK: - Styling

    private func configureNavigationBar() {
        navigationBar.isTranslucent = false
        navigationBar.prefersLargeTitles = true
        navigationBar.barTintColor = UIColor.counters.background
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
}

extension MainNavigationController: UINavigationControllerDelegate {

    /// Sets up the navigationItem for a presented view controller.
    /// This enforces the implementation of the procotol (and the protocol itself) to
    /// define navigation/toolbar elements rather than the view controller configuring
    /// everything by itself (risking consistancy).
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        setupStyle(on: viewController)
    }

    private func setupStyle(on viewController: UIViewController) {
        if let viewController = viewController as? TopBarProvider {
            let navigationItem = viewController.navigationItem
            navigationItem.backButtonTitle = viewController.topBarBackButtonText
            navigationItem.leftBarButtonItems = viewController.topBarLeftItems
            navigationItem.rightBarButtonItems = viewController.topBarRightItems
            navigationItem.title = viewController.topBarTitle
        }

        if let viewController = viewController as? BottomBarProvider {
            let leftItems = viewController.bottomBarLeftItems ?? []
            let rightItems = viewController.bottomBarRightItems ?? []
            let centerText = viewController.bottomBarCenterText

            let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

            let textLabel = UILabel()
            textLabel.text = centerText
            textLabel.textColor = UIColor.counters.descriptionText
            let centerTextItem = UIBarButtonItem(customView: textLabel)

            let items: [UIBarButtonItem] = leftItems + [
                flexibleSpaceItem,
                centerTextItem,
                flexibleSpaceItem
            ] + rightItems

            (viewController as UIViewController).toolbarItems = items
            setToolbarHidden(items.isEmpty, animated: false)
        }
    }
}
