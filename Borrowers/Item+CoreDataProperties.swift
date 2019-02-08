//
//  Item+CoreDataProperties.swift
//  Borrowers
//
//  Created by Wojciech Karaś on 29/01/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var date: NSDate
    @NSManaged public var itemDescription: String
    @NSManaged public var borrower: Borrower

}
