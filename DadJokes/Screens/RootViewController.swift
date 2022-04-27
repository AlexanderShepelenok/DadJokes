//
//  RootViewController.swift
// 
//
//  Created by Aleksandr on 11/04/22.
//

import UIKit
import CoreLayer

final class RootViewController: UIViewController, UIViewControllerRestoration {

    static func viewController(withRestorationIdentifierPath identifierComponents: [String],
                               coder: NSCoder) -> UIViewController? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let serviceContainer = appDelegate.serviceContainer else { return nil }
        return ViewControllerFactory(serviceContainer: serviceContainer).createRootViewController(coder)
    }

    private enum CodingKeys {
        static let name = "name"
    }

    private let viewControllerFactory: ViewControllerFactory
    private let jokeRepository: JokeRepository

    init?(coder: NSCoder,
          jokeRepository: JokeRepository,
          viewControllerFactory: ViewControllerFactory) {
        self.viewControllerFactory = viewControllerFactory
        self.jokeRepository = jokeRepository
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
    private func createFavoritesViewController(_ coder: NSCoder) -> FavoritesTableViewController? {
        viewControllerFactory.createFavoritesViewController(coder)
    }
}
