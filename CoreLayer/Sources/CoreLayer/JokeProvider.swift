//
//  JokeProvider.swift
//  
//
//  Created by Aleksandr Shepelenok on 4/25/22.
//

protocol JokeProvider {
    func randomJoke() async throws -> DisplayableJoke
}
