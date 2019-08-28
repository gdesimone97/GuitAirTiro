//
//  Games+CoreDataProperties.swift
//  Test1_SceneKit iOS
//
//  Created by Christian Marino on 28/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//
//

import Foundation
import CoreData


extension Games {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Games> {
        return NSFetchRequest<Games>(entityName: "Games")
    }

    @NSManaged public var progrGamesSerialized: NSData?
    @NSManaged public var last_server_read: NSDate?
    @NSManaged public var endedGamesSerialized: NSData?

}
