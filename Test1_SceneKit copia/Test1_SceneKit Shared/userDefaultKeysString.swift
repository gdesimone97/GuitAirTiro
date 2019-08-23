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
let GAME_DEVICE_SETTINGS = "game_device_settings"
let AUDIO_FILE_NAME = "audio_file_name"
let IMAGE_DEFAULT = "image_default"
let JWT_STRING = "jwt"
let TOKEN = "token"

let userDefault = UserDefaults.standard

enum TvSettings: Int {
    case withWatch = 0
    case withOutWatch = 1
}

enum TypeOfGuitar: Int {
    case electric = 1
    case classic = 2
}

func selectGuitar(_ guitar: TypeOfGuitar) -> String {
    switch guitar {
    case .classic:
        return "classic"
    case .electric:
        return "electric"
    default:
        break
    }
}

func selectGuitar(_ guitar: String) -> TypeOfGuitar? {
    switch guitar {
    case "classic":
        return .classic
    case "electric":
        return .electric
    default:
        return nil
    }
}

extension UserDefaults {
    class func setGuitar(guitar: TypeOfGuitar, forKey: String) {
        UserDefaults.standard.set(guitar.rawValue, forKey: forKey)
    }
    
    class func getGuitar(forKey: String) -> TypeOfGuitar? {
        let guitInt = UserDefaults.standard.integer(forKey: forKey)
        if guitInt ==  0 { return nil }
        return TypeOfGuitar.init(rawValue: guitInt)!
    }
}
