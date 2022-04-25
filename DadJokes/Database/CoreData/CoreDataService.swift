//
//  CoreDataService.swift
//  DadJokes
//
//  Created by Aleksandr on 06/04/22.
//

import Foundation
import CoreData

final class CoreDataService {

    enum OperationError: Error, LocalizedError {
        case insertError
        case fetchError(failureReason: String? = nil)
        case noData
        case emptyFetchResult

        var errorDescription: String? {
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

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DadJokesData")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Jokes

    public func saveJokeInBackground(joke: DadJoke) async throws -> NSManagedObjectID {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergePolicy(merge: .errorMergePolicyType)
        return try await backgroundContext.perform {
            let jokeEntity = CoreDataJoke.entity()
            do {
                let jokeObject = CoreDataJoke(entity: jokeEntity, insertInto: backgroundContext)
                jokeObject.id = joke.id
                jokeObject.text = joke.joke
                jokeObject.addedOn = Date()

                // Should throw an error in case of duplicate
                try backgroundContext.save()

                return jokeObject.objectID
            } catch {
                // Error may be thrown in case we already have this joke in the database
                // Try to return database object ID
                let databaseError = error as NSError
                if let conflictList = databaseError.userInfo["conflictList"] as? [NSObject],
                   let conflict = conflictList.first as? NSConstraintConflict,
                   let databaseObject = conflict.databaseObject {
                    return databaseObject.objectID
                }
                throw OperationError.insertError
            }
        }
    }

    public func fetchRandomJokeForDisplay() async throws -> CoreDataJoke {
        let viewContext = persistentContainer.viewContext
        return try await viewContext.perform {
            let fetchRequest = CoreDataJoke.fetchRequest()
            do {
                let totalResults = try viewContext.count(for: fetchRequest)
                guard totalResults > 0 else {
                    throw OperationError.noData
                }
                fetchRequest.fetchOffset = Int.random(in: 0..<totalResults)
                fetchRequest.fetchLimit = 1
                let result = try viewContext.fetch(fetchRequest)
                guard let fetchedJoke = result.first else {
                    throw OperationError.emptyFetchResult
                }
                return fetchedJoke
            } catch {
                throw OperationError.fetchError(failureReason: error.localizedDescription)
            }
        }
    }

    public func jokesCount() async -> Int {
        let fetchRequest = CoreDataJoke.fetchRequest()
        do {
            return try persistentContainer.viewContext.count(for: fetchRequest)
        } catch { return 0 }
    }

    // MARK: - Generic

    func objectForDisplay<T>(withID objectID: NSManagedObjectID) async throws -> T {
        let viewContext = persistentContainer.viewContext
        return try await viewContext.perform {
            guard let object = viewContext.object(with: objectID) as? T else {
                throw OperationError.fetchError()
            }
            return object
        }
    }

    // MARK: - Favorites

    typealias JokesResultsController = NSFetchedResultsController<CoreDataJoke>
    public func createFavoritesFetchedResultsController() -> JokesResultsController {
        let fetchRequest = CoreDataJoke.favoritesFetchRequest()
        let viewContext = persistentContainer.viewContext
        let fetchedResultsController = JokesResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        return fetchedResultsController
    }

    public func setInFavorites(_ inFavorites: Bool, joke: CoreDataJoke) async {
        let viewContext = persistentContainer.viewContext
        await viewContext.perform {
            joke.inFavorites = inFavorites
            try? viewContext.save()
        }
    }

}
