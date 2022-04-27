//
//  DisplayableJoke.swift
//  
//
//  Created by Aleksandr Shepelenok on 4/26/22.
//

import Foundation

@MainActor
public protocol DisplayableJoke {
    var text: String { get }
    var addedOn: Date { get }
    var inFavorites: Bool { get }
}
