//
//  URLSessionService.swift
//  
//
//  Created by Aleksandr Shepelenok on 4/26/22.
//

import CoreLayer

public final class URLSessionService: AsyncRequestService, NetworkService {

    override public init() {}

    public func randomJoke() async throws -> DecodableJoke {
        try await sendRequest(endpoint: DadJokeAPI.randomJoke, responseType: DecodableJoke.self)
    }
}
