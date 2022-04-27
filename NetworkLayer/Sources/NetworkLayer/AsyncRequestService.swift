//
//  AsyncRequestService.swift
//
//
//  Created by Aleksandr on 14/03/22.
//

import Foundation
import CoreLayer

public class AsyncRequestService {

    let urlSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    let decoder: JSONDecoder = JSONDecoder()

    func sendRequest<T: Decodable>(endpoint: Endpoint,
                                   responseType: T.Type) async throws
    -> T {
        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            throw NetworkServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        do {
            let (data, response) = try await urlSession.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                throw NetworkServiceError.emptyResponse
            }

            switch response.statusCode {
            case 200...299:
                guard let decodedResponse = try? decoder.decode(responseType, from: data) else {
                    throw NetworkServiceError.decoding
                }
                return decodedResponse
            case 401:
                throw NetworkServiceError.unauthorized
            default:
                throw NetworkServiceError.unexpectedStatusCode
            }
        } catch {
            throw NetworkServiceError.unknown
        }
    }
}
