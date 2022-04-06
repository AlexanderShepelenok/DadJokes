//
//  ViewControllerFactory.swift
//  DadJokes
//
//  Created by Aleksandr on 11/04/22.
//

import Foundation
import CoreData

final class ViewControllerFactory {

    let serviceContainer: ServiceContainer

    lazy var dadJokeRepository: DadJokeRepository = {
        DadJokeRepository(requestService: serviceContainer.requestService,
                          storage: serviceContainer.coreDataService)
    }()

    init(serviceContainer: ServiceContainer) {
        self.serviceContainer = serviceContainer
    }

    func createRootViewController(_ coder: NSCoder) -> RootViewController? {
        RootViewController(coder: coder,
                           dadJokeRepository: dadJokeRepository,
                           viewControllerFactory: self)
    }

    func createDadJokeViewController(_ coder: NSCoder) -> DadJokeViewController? {
        DadJokeViewController(coder: coder, dadJokeRepository: dadJokeRepository)
    }

    func createSignInViewController(_ coder: NSCoder) -> SignInViewController? {
        SignInViewController(coder: coder,
                             viewControllerFactory: self,
                             dadJokeRepository: dadJokeRepository)
    }

    func createFavoritesViewController(_ coder: NSCoder) -> FavoritesTableViewController? {
        guard let user = dadJokeRepository.currentUser else {
            fatalError("Cannot create favorites view controller for empty user")
        }
        let coreDataService = serviceContainer.coreDataService
        let fetchedResultsController = coreDataService.resultsController(forUser: user)
        return FavoritesTableViewController(coder: coder,
                                            fetchedResultsController: fetchedResultsController)
    }
}
