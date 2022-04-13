//
//  DadJokeRepository.swift
//  DadJokes
//
//  Created by Aleksandr on 07/04/22.
//

import Foundation

final class DadJokeRepository {

    private let requestService: DadJokeRequestService
    private let coreData: CoreDataService

    init(requestService: DadJokeRequestService, storage: CoreDataService) {
        self.requestService = requestService
        self.coreData = storage
    }

    // MARK: - Repository access methods

    func randomJoke() async throws -> CoreDataJoke {
        let result = await requestService.randomJoke()
        switch result {
            case .success(let joke):
                let jokeObjectID = try await coreData.saveJokeInBackground(joke: joke)
                let jokeForDisplay: CoreDataJoke = try await coreData.objectForDisplay(withID: jokeObjectID)
                return jokeForDisplay
            case .failure:
                return try await coreData.fetchRandomJokeForDisplay()
        }
    }

    func databaseJokesCount() async -> Int {
        await coreData.jokesCount()
    }

    func addToFavorites(joke: CoreDataJoke) {
        coreData.addToFavorites(joke)
    }
}
