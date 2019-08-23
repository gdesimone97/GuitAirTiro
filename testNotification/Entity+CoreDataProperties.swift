//
//  Entity+CoreDataProperties.swift
//  testNotification
//
//  Created by Giuseppe De Simone on 21/08/2019.
//  Copyright © 2019 Giuseppe De Simone. All rights reserved.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var test: String?

}
