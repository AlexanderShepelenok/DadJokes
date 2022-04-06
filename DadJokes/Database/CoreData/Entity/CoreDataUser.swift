//
//  CoreDataUser.swift
//  DadJokes
//
//  Created by Aleksandr on 31/03/22.
//

import Foundation
import CoreData

final class CoreDataUser: NSManagedObject, Identifiable {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CoreDataUser> {
        NSFetchRequest<CoreDataUser>(entityName: "User")
    }

    @nonobjc
    public class func fetchRequest(forName name: String) -> NSFetchRequest<CoreDataUser> {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        return request
    }

    @NSManaged public var name: String?
    @NSManaged public var jokes: NSSet?

    @objc(addJokesObject:)
    @NSManaged public func addToJokes(_ value: CoreDataJoke)

    @objc(removeJokesObject:)
    @NSManaged public func removeFromJokes(_ value: CoreDataJoke)

    @objc(addJokes:)
    @NSManaged public func addToJokes(_ values: NSSet)

    @objc(removeJokes:)
    @NSManaged public func removeFromJokes(_ values: NSSet)
}
