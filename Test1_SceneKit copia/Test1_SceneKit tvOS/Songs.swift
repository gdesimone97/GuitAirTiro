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
    var title: String!
    var author: String!
    var base: String?
    var notes: String!
    var chords: [String]!
    
    init(title: String, author: String, base: String?, chords: [String], notes: String) {
        self.title = title
        self.author = author
        self.notes = notes
        self.base = base
        self.chords = chords
    }
    
    static var LaCanzoneDelSole: Songs { return Songs(title: "La canzone del sole", author: "LucioBattisti.jpg", base: nil, chords: ["", "", "", ""], notes: "1:319149;1:319149;1:638298;2:319149;2:319149;2:638298;3:319149;3:319149;3:638298;2:319149;2:319149;2:638298;1:319149;1:319149;1:638298;2:319149;2:319149;2:638298;3:319149;3:319149;3:638298;2:319149;2:319149;2:638298;1:319149;1:319149;1:638298;2:319149;2:319149;2:638298;3:319149;3:319149;3:638298;2:319149;2:319149;2:638298;1:319149;1:319149;1:638298;2:319149;2:319149;2:638298;3:319149;3:319149;3:638298;2:319149;2:319149;2:638298;") }
    
    static var PeppeGay: Songs { return Songs(title: "Peppe song", author: "Gennaro", base: nil, chords: ["", "", "", ""], notes: "3:2:500000;1:500000;4:500000;1:3:500000;") }
    
    static var KnockinOnHeavensDoor: Songs { return Songs(title: "Knockin' on Heavens Door", author: "BobDylan.jpg", base: "KnockinOnHeavensDoor.mp3", chords: ["G.wav", "D.wav", "Am.wav", "C.wav"], notes: "0:1725350;1:837404;1:837404;2:837404;2:837404;3:837404;3:837404;3:837404;3:837404;1:837404;1:837404;2:837404;2:837404;4:837404;4:837404;4:837404;4:837404;1:837404;1:837404;2:837404;2:837404;3:837404;3:837404;3:837404;3:837404;1:837404;1:837404;2:837404;2:837404;4:837404;4:837404;4:837404;4:837404;1:837404;1:837404;2:837404;2:837404;3:837404;3:837404;3:837404;3:837404;1:837404;1:837404;2:837404;2:837404;4:837404;4:837404;4:837404;4:837404;1:837404;1:837404;2:837404;2:837404;3:837404;3:837404;3:837404;3:837404;1:837404;1:837404;2:837404;2:837404;4:837404;4:837404;4:837404;4:837404;1:837404;1:837404;2:837404;2:837404;3:837404;3:837404;3:837404;3:837404;1:837404;1:837404;2:837404;2:837404;4:837404;4:837404;4:837404;4:837404;1:837404;1:837404;2:837404;2:837404;3:837404;3:837404;3:837404;3:837404;1:837404;1:837404;2:837404;2:837404;4:837404;4:837404;4:837404;4:837404;")}
    
    static var songs: [Int : Songs] { return [1: Songs.KnockinOnHeavensDoor, 2: Songs.LaCanzoneDelSole, 3: Songs.PeppeGay] }
}

extension Songs: Equatable {
    static func ==(lhs: Songs, rhs: Songs) -> Bool {
        return lhs.title == rhs.title
    }
}
