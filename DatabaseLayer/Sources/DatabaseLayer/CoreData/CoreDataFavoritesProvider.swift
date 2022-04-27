//
//  CoreDataFavoritesProvider.swift
// 
//
//  Created by Aleksandr Shepelenok on 4/25/22.
//

import CoreData
import CoreLayer

final class CoreDataFavoritesProvider: NSObject, FavoritesProvider {
    weak var delegate: FavoritesProviderDelegate?

    private let viewContext: NSManagedObjectContext

    lazy var fetchedResultsController: NSFetchedResultsController<CoreDataJoke> = {
        let fetchRequest = CoreDataJoke.favoritesFetchRequest()
        let controller = NSFetchedResultsController<CoreDataJoke>(fetchRequest: fetchRequest,
                                                        managedObjectContext: viewContext,
                                                        sectionNameKeyPath: nil,
                                                        cacheName: nil)
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            delegate?.fetchingFailed(error: error)
        }
        return controller
    }()

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func numberOfSections() -> Int {
        fetchedResultsController.sections?.count ?? 0
    }

    func numberOfItems(inSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }

    func item(at indexPath: IndexPath) -> DisplayableJoke {
        fetchedResultsController.object(at: indexPath)
    }

}

extension CoreDataFavoritesProvider: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChangeContentWith diff: CollectionDifference<NSManagedObjectID>) {
        delegate?.favoritesUpdated(insertionsCount: diff.insertions.count, removalsCount: diff.removals.count)
    }
}
