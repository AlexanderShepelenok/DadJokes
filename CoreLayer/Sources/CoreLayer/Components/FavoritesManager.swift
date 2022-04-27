//
//  FavoritesManager.swift
//  
//
//  Created by Aleksandr Shepelenok on 4/25/22.
//

public protocol FavoritesManager {
    func setFavorite(_ isFavorite: Bool, joke: DisplayableJoke) async
}
