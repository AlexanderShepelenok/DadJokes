//
//  Endpoint.swift
//  DadJokes
//
//  Created by Aleksandr on 16/03/22.
//

import Foundation

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headers: [String: String] { get }
}
