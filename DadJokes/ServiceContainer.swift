//
//  ServiceContainer.swift
//  
//
//  Created by Aleksandr Shepelenok on 4/26/22.
//

import CoreLayer

public final class ServiceContainer {
    public let databaseService: DatabaseService
    public let networkService: NetworkService
    public let favoritesManager: FavoritesManager
    public let favoritesProviderCreator: FavoritesProviderCreator

    public init(databaseService: DatabaseService,
                networkService: NetworkService,
                favoritesManager: FavoritesManager,
                favoritesProviderCreator: FavoritesProviderCreator) {
        self.databaseService = databaseService
        self.networkService = networkService
        self.favoritesManager = favoritesManager
        self.favoritesProviderCreator = favoritesProviderCreator
    }
}
