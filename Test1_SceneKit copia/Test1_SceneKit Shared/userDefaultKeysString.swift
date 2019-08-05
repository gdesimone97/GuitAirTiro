//
//  userDefaultKeysString.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 01/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

let USER_DEFAULT_KEY_ROW = "chords_row"
let USER_DEFAULT_KEY_STRING = "chords_string"
let USER_LANGUAGE = "PreferredNotation"
let GUITAR = "guitar_selected"
let LOGIN = "login_user"

let userDefault = UserDefaults.standard


enum GuitarType: Int {
    case elettric = 0
    case classic = 1
}

extension UserDefaults {
    class func setGuitar(guitar: GuitarType, forKey: String) {
        UserDefaults.standard.set(guitar.rawValue, forKey: GUITAR)
    }
    
    class func getGuitar(forKey: String) -> GuitarType? {
        let guitInt = UserDefaults.standard.integer(forKey: GUITAR)
        if guitInt ==  0 { return nil }
        return GuitarType.init(rawValue: guitInt)!
    }
}
