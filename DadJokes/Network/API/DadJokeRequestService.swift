//
//  DadJokeRequestService.swift
//  DadJokes
//
//  Created by Aleksandr on 16/03/22.
//

import Foundation

final class DadJokeRequestService: AsyncRequestService {

    func randomJoke() async -> Result<DadJoke, AsyncRequestServiceError> {
        await sendRequest(endpoint: DadJokeAPI.randomJoke, responseType: DadJoke.self)
    }

    func specificJoke(withId jokeId: String) async -> Result<DadJoke, AsyncRequestServiceError> {
        await sendRequest(endpoint: DadJokeAPI.specificJoke(jokeId: jokeId), responseType: DadJoke.self)
    }
}
