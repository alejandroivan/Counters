import UIKit

final class MainViewController: UIViewController {

    fileprivate var counters: [String] = ["a", "b", "c"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.counters.background
    }

}

extension MainViewController: TopBarProvider {

    var topBarTitle: String? { "Counters" }

    var topBarBackButtonText: String? {
        nil
    }

    var topBarLeftItems: [UIBarButtonItem]? {
        guard !counters.isEmpty else { return nil }
        let item = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        return [item]
    }

    var topBarRightItems: [UIBarButtonItem]? { [] }
}

extension MainViewController: BottomBarProvider {
    var showsBottomBar: Bool { true }

    var bottomBarLeftItems: [UIBarButtonItem]? { [] }

    var bottomBarCenterText: String? {
        "Testing"
    }

    var bottomBarRightItems: [UIBarButtonItem]? {
        [
            UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        ]
    }
}
