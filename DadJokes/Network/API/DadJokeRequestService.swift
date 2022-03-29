//
//  DadJokeRequestService.swift
//  DadJokes
//
//  Created by Aleksandr on 16/03/22.
//

import Foundation

final class DadJokeRequestService: AsyncRequestService {

    func getRandomJoke() async -> Result<DadJoke, AsyncRequestServiceError> {
        return await sendRequest(endpoint: DadJokeAPI.randomJoke, responseType: DadJoke.self)
    }

    func getSpecificJoke(withId jokeId: String) async -> Result<DadJoke, AsyncRequestServiceError> {
        return await sendRequest(endpoint: DadJokeAPI.specificJoke(jokeId: jokeId), responseType: DadJoke.self)
    }
}
