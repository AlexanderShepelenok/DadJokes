//
//  DadJokeAPI.swift
// 
//
//  Created by Aleksandr on 14/03/22.
//

import UIKit

enum DadJokeAPI: Endpoint {
    case randomJoke
    case specificJoke(jokeId: String)

    var baseURL: String { "https://icanhazdadjoke.com/" }

    var path: String {
        switch self {
            case .randomJoke:
                return ""
            case .specificJoke(let jokeId):
                return "/j/\(jokeId)"
        }
    }

    var httpMethod: HTTPMethod { .get }

    var headers: [String: String] { ["Accept": "application/json"] }
}
