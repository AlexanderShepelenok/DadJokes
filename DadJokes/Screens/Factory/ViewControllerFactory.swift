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

    func createFavoritesViewController(_ coder: NSCoder) -> FavoritesTableViewController? {
        let coreDataService = serviceContainer.coreDataService
        let fetchedResultsController = coreDataService.createFavoritesFetchedResultsController()
        return FavoritesTableViewController(coder: coder,
                                            fetchedResultsController: fetchedResultsController)
    }
}
