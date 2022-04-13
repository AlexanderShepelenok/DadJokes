//
//  CoreDataJoke.swift
//  DadJokes
//
//  Created by Aleksandr on 31/03/22.
//

import Foundation
import CoreData

final class CoreDataJoke: NSManagedObject, Identifiable {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CoreDataJoke> {
        NSFetchRequest<CoreDataJoke>(entityName: "Joke")
    }

    @nonobjc
    public class func favoritesFetchRequest() -> NSFetchRequest<CoreDataJoke> {
        let fetchRequest = fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "inFavorites == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "addedOn", ascending: false)]
        return fetchRequest
    }

    @NSManaged public var id: String
    @NSManaged public var text: String
    @NSManaged public var addedOn: Date
    @NSManaged public var inFavorites: Bool
}
