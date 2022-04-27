//
//  JokeRepository.swift
//  
//
//  Created by Aleksandr on 07/04/22.
//

public final class JokeRepository: JokeProvider {

    private let networkService: NetworkService
    private let databaseService: DatabaseService

    public init(networkService: NetworkService, databaseService: DatabaseService) {
        self.networkService = networkService
        self.databaseService = databaseService
    }

    public func randomJoke() async throws -> DisplayableJoke {
        do {
            let joke = try await networkService.randomJoke()
            return try await databaseService.saveAndReturnForDisplay(joke: joke)
        } catch {
            return try await databaseService.fetchRandomJokeForDisplay()
        }
    }

}
