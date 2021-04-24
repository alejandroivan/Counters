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
        configureNavigationBar()
    }

    // MARK: - Styling

    private func configureNavigationBar() {
        navigationBar.isTranslucent = false
        navigationBar.setBackgroundImage(nil, for: .default)
    }
}

extension MainNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let viewController = viewController as? TopBarProvider else { return }
    }
}
