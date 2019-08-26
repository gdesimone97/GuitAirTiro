//
//  Songs.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 07/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import Foundation

//enum Songs {
//    typealias RawValue = SongsType
//
//    case LaCanzoneDelSole = SongsType(author: "LucioBattisti", notes: "1:319149;1:319149;1:638298;2:319149;2:319149;2:638298;3:319149;3:319149;3:638298;2:319149;2:319149;2:638298;1:319149;1:319149;1:638298;2:319149;2:319149;2:638298;3:319149;3:319149;3:638298;2:319149;2:319149;2:638298;1:319149;1:319149;1:638298;2:319149;2:319149;2:638298;3:319149;3:319149;3:638298;2:319149;2:319149;2:638298;1:319149;1:319149;1:638298;2:319149;2:319149;2:638298;3:319149;3:319149;3:638298;2:319149;2:319149;2:638298;")
//    case PeppeGay = SongsType(author: "Gennaro", notes: "3:2:500000;1:500000;4:500000;1:3:500000;")
//}

struct Songs {
    var author: String!
    var notes: String!
    
    init(author: String, notes: String) {
        self.author = author
        self.notes = notes
    }
    
    static var LaCanzoneDelSole: Songs { return Songs(author: "LucioBattisti.jpg", notes: "1:319149;1:319149;1:638298;2:319149;2:319149;2:638298;3:319149;3:319149;3:638298;2:319149;2:319149;2:638298;1:319149;1:319149;1:638298;2:319149;2:319149;2:638298;3:319149;3:319149;3:638298;2:319149;2:319149;2:638298;1:319149;1:319149;1:638298;2:319149;2:319149;2:638298;3:319149;3:319149;3:638298;2:319149;2:319149;2:638298;1:319149;1:319149;1:638298;2:319149;2:319149;2:638298;3:319149;3:319149;3:638298;2:319149;2:319149;2:638298;") }
    
    static var PeppeGay: Songs { return Songs(author: "Gennaro", notes: "3:2:500000;1:500000;4:500000;1:3:500000;") }
    
    static var KnockinOnHeavensDoor: Songs { return Songs(author: "BobDylan.jpg", notes: "1:845070;1:845070;2:845070;2:845070;3:845070;3:845070;3:845070;3:845070;1:845070;1:845070;2:845070;2:845070;4:845070;4:845070;4:845070;4:845070;1:845070;1:845070;2:845070;2:845070;3:845070;3:845070;3:845070;3:845070;1:845070;1:845070;2:845070;2:845070;4:845070;4:845070;4:845070;4:845070;1:845070;1:845070;2:845070;2:845070;3:845070;3:845070;3:845070;3:845070;1:845070;1:845070;2:845070;2:845070;4:845070;4:845070;4:845070;4:845070;1:845070;1:845070;2:845070;2:845070;3:845070;3:845070;3:845070;3:845070;1:845070;1:845070;2:845070;2:845070;4:845070;4:845070;4:845070;4:845070;1:845070;1:845070;2:845070;2:845070;3:845070;3:845070;3:845070;3:845070;1:845070;1:845070;2:845070;2:845070;4:845070;4:845070;4:845070;4:845070;1:845070;1:845070;2:845070;2:845070;3:845070;3:845070;3:845070;3:845070;1:845070;1:845070;2:845070;2:845070;4:845070;4:845070;4:845070;4:845070;")}
}

