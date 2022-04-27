//
//  FavoritesProvider.swift
//  
//
//  Created by Aleksandr Shepelenok on 4/25/22.
//

import Foundation

public protocol FavoritesProvider: AnyObject {
    var delegate: FavoritesProviderDelegate? { get set }

    func numberOfSections() -> Int
    func numberOfItems(inSection section: Int) -> Int
    func item(at: IndexPath) -> DisplayableJoke
}

public protocol FavoritesProviderDelegate: AnyObject {
    func fetchingFailed(error: Error)
    func favoritesUpdated(insertionsCount: Int, removalsCount: Int)
}
