//
//  ServiceContainer.swift
//  DadJokes
//
//  Created by Aleksandr on 11/04/22.
//

import Foundation

final class ServiceContainer {
    let coreDataService = CoreDataService()
    let requestService = DadJokeRequestService()
}
