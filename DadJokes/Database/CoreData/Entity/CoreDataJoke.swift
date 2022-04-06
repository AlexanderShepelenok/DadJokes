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
    public class func fetchRequest(forUser user: CoreDataUser) -> NSFetchRequest<CoreDataJoke> {
        let fetchRequest = fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ANY users == %@", user)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "addedOn", ascending: false)]
        return fetchRequest
    }

    @NSManaged public var id: String
    @NSManaged public var text: String
    @NSManaged public var addedOn: Date
    @NSManaged public var users: NSSet?

    @objc(addUsersObject:)
    @NSManaged public func addToUsers(_ value: CoreDataUser)

    @objc(removeUsersObject:)
    @NSManaged public func removeFromUsers(_ value: CoreDataUser)

    @objc(addUsers:)
    @NSManaged public func addToUsers(_ values: NSSet)

    @objc(removeUsers:)
    @NSManaged public func removeFromUsers(_ values: NSSet)
}