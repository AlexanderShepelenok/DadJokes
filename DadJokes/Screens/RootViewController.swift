//
//  RootViewController.swift
//  DadJokes
//
//  Created by Aleksandr on 11/04/22.
//

import UIKit

final class RootViewController: UIViewController, UIViewControllerRestoration {

    static func viewController(withRestorationIdentifierPath identifierComponents: [String],
                               coder: NSCoder) -> UIViewController? {
        ViewControllerFactory(serviceContainer: ServiceContainer()).createRootViewController(coder)
    }

    private enum CodingKeys {
        static let name = "name"
    }

    private let viewControllerFactory: ViewControllerFactory
    private let dadJokeRepository: DadJokeRepository

    init?(coder: NSCoder,
          dadJokeRepository: DadJokeRepository,
          viewControllerFactory: ViewControllerFactory) {
        self.viewControllerFactory = viewControllerFactory
        self.dadJokeRepository = dadJokeRepository
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Segue actions

    @IBSegueAction
    private func createDadJokeViewController(_ coder: NSCoder) -> DadJokeViewController? {
        viewControllerFactory.createDadJokeViewController(coder)
    }

    @IBSegueAction
    private func createSignInViewController(_ coder: NSCoder) -> SignInViewController? {
        viewControllerFactory.createSignInViewController(coder)
    }

}
