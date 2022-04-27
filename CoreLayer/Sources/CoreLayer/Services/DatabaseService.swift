//
//  DatabaseService.swift
//  
//
//  Created by Aleksandr Shepelenok on 4/26/22.
//

public protocol DatabaseService {
    func saveAndReturnForDisplay(joke: DecodableJoke) async throws -> DisplayableJoke
    func fetchRandomJokeForDisplay() async throws -> DisplayableJoke
}
