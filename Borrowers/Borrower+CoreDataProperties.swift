//
//  Borrower+CoreDataProperties.swift
//  Borrowers
//
//  Created by Wojciech Karaś on 29/01/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//
//

import Foundation
import CoreData


extension Borrower {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Borrower> {
        return NSFetchRequest<Borrower>(entityName: "Borrower")
    }

    @NSManaged public var email: String?
    @NSManaged public var name: String
    @NSManaged public var photo: NSData?
    @NSManaged public var items: NSSet

}

// MARK: Generated accessors for items
extension Borrower {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
