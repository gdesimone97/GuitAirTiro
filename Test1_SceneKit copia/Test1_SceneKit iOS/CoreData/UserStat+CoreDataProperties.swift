//
//  UserStat+CoreDataProperties.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 21/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//
//

import Foundation
import CoreData


extension UserStat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserStat> {
        return NSFetchRequest<UserStat>(entityName: "UserStat")
    }

    @NSManaged public var gamerTag: String?
    @NSManaged public var image: NSData?
    @NSManaged public var wins: Int64
    @NSManaged public var draws: Int64
    @NSManaged public var lose: Int64

}
