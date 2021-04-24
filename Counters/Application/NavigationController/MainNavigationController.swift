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
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let topBarProvider = viewController as? TopBarProvider {
            let navigationItem = viewController.navigationItem
            navigationItem.backButtonTitle = topBarProvider.topBarBackButtonText
            navigationItem.leftBarButtonItems = topBarProvider.topBarLeftItems
            navigationItem.rightBarButtonItems = topBarProvider.topBarRightItems
            navigationItem.title = topBarProvider.topBarTitle
        }
    }
}
