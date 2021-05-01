import UIKit

public typealias BarProvider = TopBarProvider & BottomBarProvider

final class MainNavigationController: UINavigationController {

    // MARK: - Styling

    private struct Constants {
        static let itemColor = UIColor.counters.accent
        static let barColor = UIColor.counters.barBackground
    }

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
        configureToolBar()
    }

    // MARK: - Styling
    
    public func updateBars(for viewController: UIViewController) {
        setupStyle(on: viewController)
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Constants.barColor

        navigationBar.isTranslucent = false
        navigationBar.prefersLargeTitles = true
        navigationBar.tintColor = Constants.itemColor
        navigationBar.setBackgroundImage(UIImage(), for: .default)

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }

    private func configureToolBar() {
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Constants.barColor

        toolbar.isTranslucent = false
        toolbar.standardAppearance = appearance
        toolbar.tintColor = Constants.itemColor
    }
}

extension MainNavigationController: UINavigationControllerDelegate {

    /// Sets up the navigationItem for a presented view controller.
    /// This enforces the implementation of the procotol (and the protocol itself) to
    /// define navigation/toolbar elements rather than the view controller configuring
    /// everything by itself (risking consistency).
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

            let navigationBar = viewController.navigationController?.navigationBar
            navigationBar?.prefersLargeTitles = viewController.topBarPrefersLargeTitles
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

            viewController.toolbarItems = items
            setToolbarHidden(items.isEmpty, animated: false)
        }
    }
}
