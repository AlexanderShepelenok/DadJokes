//
//  ViewControllerFactory.swift
//  DadJokes
//
//  Created by Aleksandr on 11/04/22.
//

import Foundation
import CoreLayer

final class ViewControllerFactory {

    let serviceContainer: ServiceContainer

    lazy var jokeRepository: JokeRepository = {
        JokeRepository(networkService: serviceContainer.networkService,
                       databaseService: serviceContainer.databaseService)
    }()

    init(serviceContainer: ServiceContainer) {
        self.serviceContainer = serviceContainer
    }

    func createRootViewController(_ coder: NSCoder) -> RootViewController? {
        RootViewController(coder: coder,
                           jokeRepository: jokeRepository,
                           viewControllerFactory: self)
    }

    func createDadJokeViewController(_ coder: NSCoder) -> DadJokeViewController? {
        DadJokeViewController(coder: coder,
                              jokeRepository: jokeRepository,
                              favoritesManager: serviceContainer.favoritesManager)
    }

    func createFavoritesViewController(_ coder: NSCoder) -> FavoritesTableViewController? {
        let creator = serviceContainer.favoritesProviderCreator
        let provider = creator.createFavoritesProvider()
        return FavoritesTableViewController(coder: coder,
                                            favoritesProvider: provider,
                                            favoritesManager: serviceContainer.favoritesManager)
    }
}
