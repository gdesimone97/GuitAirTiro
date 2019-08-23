//
//  Stat+CoreDataProperties.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 21/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//
//

import Foundation
import CoreData


extension Stat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stat> {
        return NSFetchRequest<Stat>(entityName: "Stat")
    }

    @NSManaged public var draws: Int64
    @NSManaged public var gamerTag: String?
    @NSManaged public var image: NSData?
    @NSManaged public var losses: Int64
    @NSManaged public var score: Int64
    @NSManaged public var wins: Int64

}
