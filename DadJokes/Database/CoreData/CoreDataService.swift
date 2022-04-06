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
        backgroundContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        logCurrentThread()
        return try await backgroundContext.perform {
            logCurrentThread()
            let jokeEntity = CoreDataJoke.entity()
            do {
                let jokeObject = CoreDataJoke(entity: jokeEntity, insertInto: backgroundContext)
                jokeObject.id = joke.id
                jokeObject.text = joke.joke
                jokeObject.addedOn = Date()

                // Should throw an error in case of duplicate
                // Update merge policy to not throw an error
                try backgroundContext.save()

                return jokeObject.objectID
            } catch {
                throw OperationError.insertError
            }
        }
    }

    public func fetchRandomJokeForDisplay() async throws -> CoreDataJoke {
        let viewContext = persistentContainer.viewContext
        logCurrentThread()
        return try await viewContext.perform {
            logCurrentThread()
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
//        logCurrentThread()
        return try await viewContext.perform {
//            logCurrentThread()
            guard let object = viewContext.object(with: objectID) as? T else {
                throw OperationError.fetchError()
            }
            return object
        }
    }

    // MARK: - User

    public func user(withName name: String) async throws -> CoreDataUser {
        let isUserExist = try await isUserExist(name: name)
        if !isUserExist {
            let userObjectID = try await createUser(withName: name)
            let user: CoreDataUser = try await objectForDisplay(withID: userObjectID)
            return user
        } else {
            return try await userForDisplay(withName: name)
        }
    }

    private func isUserExist(name: String) async throws -> Bool {
        let backgroundContext = persistentContainer.newBackgroundContext()
        return try await backgroundContext.perform {
            let fetchRequest = CoreDataUser.fetchRequest(forName: name)
            do {
                let userCount = try backgroundContext.count(for: fetchRequest)
                return userCount > 0
            } catch {
                throw OperationError.fetchError(failureReason: error.localizedDescription)
            }
        }
    }

    private func createUser(withName name: String) async throws -> NSManagedObjectID {
        let backgroundContext = persistentContainer.newBackgroundContext()
        return try await backgroundContext.perform {
            let userEntity = CoreDataUser.entity()
            do {
                let userObject = CoreDataUser(entity: userEntity, insertInto: backgroundContext)
                userObject.name = name

                try backgroundContext.save()
                return userObject.objectID
            } catch {
                throw OperationError.insertError
            }
        }
    }

    public func userForDisplay(withName name: String) async throws -> CoreDataUser {
        let viewContext = persistentContainer.viewContext
        return try await viewContext.perform {
            let fetchRequest = CoreDataUser.fetchRequest(forName: name)
            do {
                let users = try viewContext.fetch(fetchRequest)
                guard let user = users.first else { throw OperationError.emptyFetchResult }
                return user
            } catch {
                throw OperationError.fetchError(failureReason: error.localizedDescription)
            }
        }
    }

    // MARK: - Favorites

    typealias JokesResultsController = NSFetchedResultsController<CoreDataJoke>
    public func resultsController(forUser user: CoreDataUser) -> JokesResultsController {
        let fetchRequest = CoreDataJoke.fetchRequest(forUser: user)
        let viewContext = persistentContainer.viewContext
        let fetchedResultsController = JokesResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: viewContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        return fetchedResultsController
    }

    public func addJoke(_ joke: CoreDataJoke, toUser user: CoreDataUser) {
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            user.addToJokes(joke)
            try? viewContext.save()
        }
    }

}
