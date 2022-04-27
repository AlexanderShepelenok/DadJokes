//
//  NetworkServiceError.swift
//  
//
//  Created by Aleksandr Shepelenok on 4/26/22.
//

import Foundation

public enum NetworkServiceError: Error {
    case decoding
    case invalidURL
    case emptyResponse
    case unauthorized
    case unexpectedStatusCode
    case unknown

    var message: String {
        switch self {
        case .decoding: return "Decoding error"
        case .unauthorized: return "Unauthorized error"
        default: return "Unknown error"
        }
    }
}
