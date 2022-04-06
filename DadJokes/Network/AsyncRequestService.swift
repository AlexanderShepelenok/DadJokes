//
//  AsyncRequestService.swift
//  DadJokes
//
//  Created by Aleksandr on 14/03/22.
//

import Foundation

enum AsyncRequestServiceError: Error {
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

class AsyncRequestService {

    let urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    let decoder: JSONDecoder = JSONDecoder()

    func sendRequest<T: Decodable>(endpoint: Endpoint,
                                   responseType: T.Type) async
    -> Result<T, AsyncRequestServiceError> {
        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        do {
            let (data, response) = try await urlSession.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.emptyResponse)
            }

            switch response.statusCode {
            case 200...299:
                guard let decodedResponse = try? decoder.decode(responseType, from: data) else {
                    return .failure(.decoding)
                }
                return .success(decodedResponse)
            case 401:
                return .failure(.unauthorized)
            default:
                return .failure(.unexpectedStatusCode)
            }
        } catch {
            return .failure(.unknown)
        }
    }
}
