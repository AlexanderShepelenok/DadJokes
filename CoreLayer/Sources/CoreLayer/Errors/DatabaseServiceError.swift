//
//  DatabaseServiceError.swift
//  
//
//  Created by Aleksandr Shepelenok on 4/26/22.
//

import Foundation

public enum DatabaseServiceError: Error, LocalizedError {
    case insertError
    case fetchError(failureReason: String? = nil)
    case noData
    case emptyFetchResult

    public var errorDescription: String? {
        switch self {
            case .insertError:
                return "Unable to add object to the database"
            case .fetchError(let failureReason):
                return "Unable to fetch object from the database. \(failureReason ?? "")"
            case .noData:
                return "Database is empty"
            case .emptyFetchResult:
                return "Fetch request returned empty array"
        }
    }
}
