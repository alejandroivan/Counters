//
//  WelcomeViewController.swift
//  Counters
//
//

import UIKit

protocol WelcomeViewControllerPresenter {
    var viewModel: WelcomeView.ViewModel { get }
}

class WelcomeViewController: UIViewController {
    private lazy var innerView = WelcomeView(delegate: self)
    
    private let presenter: WelcomeViewControllerPresenter
    
    init(presenter: WelcomeViewControllerPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = innerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalSafeAreaInsets = Constants.additionalInsets
        innerView.configure(with: presenter.viewModel)
    }
}

extension WelcomeViewController: WelcomeViewButtonDelegate {
    func didPressContinueButton() {
        routeToMainScreen()
    }

    private func routeToMainScreen() {
        let viewController = MainViewController(
            presenter: MainViewControllerPresenter(
                tableViewDataSource: MainTableViewDataSource(),
                tableViewDelegate: MainTableViewDelegate(),
                useCase: MainViewControllerUseCase(
                    networking: SwiftNetworking()
                )
            )
        )
        let navigationController = MainNavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
}

private extension WelcomeViewController {
    enum Constants {
        static let additionalInsets = UIEdgeInsets(top: 26, left: 39, bottom: 20, right: 39)
    }
}
