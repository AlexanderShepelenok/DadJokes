//
//  Joke.swift
//  
//
//  Created by Aleksandr Shepelenok on 4/25/22.
//

import Foundation

public struct DecodableJoke: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case text = "joke"
    }
    public let id: String
    public let text: String
}
