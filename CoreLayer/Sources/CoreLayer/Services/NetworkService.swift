//
//  NetworkService.swift
//  
//
//  Created by Aleksandr Shepelenok on 4/26/22.
//

import Foundation

public protocol NetworkService {
    func randomJoke() async throws -> DecodableJoke
}
