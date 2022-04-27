//
//  CoreDataService.swift
// 
//
//  Created by Aleksandr on 06/04/22.
//

import Foundation
import CoreData
import CoreLayer

public final class CoreDataService: DatabaseService {

    private lazy var persistentContainer: NSPersistentContainer = {
        guard let objectModelURL = Bundle.module.url(forResource: "DadJokesData", withExtension: "momd"),
            let objectModel = NSManagedObjectModel(contentsOf: objectModelURL)
        else {
            fatalError("Failed to retrieve the object model")
        }
        let container = NSPersistentContainer(name: "DadJokesData", managedObjectModel: objectModel)
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    public init() {}

    // MARK: - DatabaseService implementation

    public func saveAndReturnForDisplay(joke: DecodableJoke) async throws -> DisplayableJoke {
        let jokeObjectID = try await saveJokeInBackground(joke: joke)
        let jokeForDisplay: CoreDataJoke = try await objectForDisplay(withID: jokeObjectID)
        return jokeForDisplay
    }

    public func fetchRandomJokeForDisplay() async throws -> DisplayableJoke {
        let viewContext = persistentContainer.viewContext
        return try await viewContext.perform {
            let fetchRequest = CoreDataJoke.fetchRequest()
            do {
                let totalResults = try viewContext.count(for: fetchRequest)
                guard totalResults > 0 else {
                    throw DatabaseServiceError.noData
                }
                fetchRequest.fetchOffset = Int.random(in: 0..<totalResults)
                fetchRequest.fetchLimit = 1
                let result = try viewContext.fetch(fetchRequest)
                guard let fetchedJoke = result.first else {
                    throw DatabaseServiceError.emptyFetchResult
                }
                return fetchedJoke
            } catch {
                throw DatabaseServiceError.fetchError(failureReason: error.localizedDescription)
            }
        }
    }

    // MARK: - Private methods

    private func saveJokeInBackground(joke: DecodableJoke) async throws -> NSManagedObjectID {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergePolicy(merge: .errorMergePolicyType)
        return try await backgroundContext.perform {
            let jokeEntity = CoreDataJoke.entity()
            do {
                let jokeObject = CoreDataJoke(entity: jokeEntity, insertInto: backgroundContext)
                jokeObject.id = joke.id
                jokeObject.text = joke.text
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
                throw DatabaseServiceError.insertError
            }
        }
    }

    private func objectForDisplay<T>(withID objectID: NSManagedObjectID) async throws -> T {
        let viewContext = persistentContainer.viewContext
        return try await viewContext.perform {
            guard let object = viewContext.object(with: objectID) as? T else {
                throw DatabaseServiceError.fetchError()
            }
            return object
        }
    }

}

extension CoreDataService: FavoritesManager {
    public func setFavorite(_ isFavorite: Bool, joke: DisplayableJoke) async {
        guard let jokeObject = joke as? CoreDataJoke else {
            fatalError("Unable to unwrap Core Data Joke object")
        }
        let viewContext = persistentContainer.viewContext
        await viewContext.perform {
            jokeObject.inFavorites = isFavorite
            try? viewContext.save()
        }
    }
}

extension CoreDataService: FavoritesProviderCreator {
    public func createFavoritesProvider() -> FavoritesProvider {
        CoreDataFavoritesProvider(viewContext: persistentContainer.viewContext)
    }
}
