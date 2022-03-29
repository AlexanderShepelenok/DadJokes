//
//  DadJokeResponse.swift
//  DadJokes
//
//  Created by Aleksandr on 17/03/22.
//

import CoreData

struct DadJoke: Decodable {
    let id: String
    let joke: String
}
