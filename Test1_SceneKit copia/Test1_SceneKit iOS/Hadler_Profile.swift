//
//  Hadler_Profile.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 27/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import Foundation
import UIKit

class HadlerProfile {
    static private let hadlerProfileThread = DispatchQueue.global(qos: .userInitiated)
    static private let semaphore = DispatchSemaphore.init(value: 1)
    static private let game = GuitAirGameCenter.share
    class func downloadProfile() {
        hadlerProfileThread.async {
            self.semaphore.wait()
            print("Risorsa acquisita")
            let res = game.getMyProfile()
            if res.0 == 200 || res.0 == 201 {
                let profile = res.1
                let score = profile["total_score"]
                let wins = profile["wins"]
                let draws = profile["draws"]
                let losses = profile["losses"]
                let gamertagString = profile["gamertag"]
                let image = profile["image"]
                PersistanceManager.UploadStat(score: Int(score!) , wins: Int(wins!) , draws: Int(draws!), losses: Int(losses!), image: convertStringToData(string: image!), gamerTag: gamertagString!)
                print("Core data aggiornato")
                semaphore.signal()
            }
            else {
                print("No comunicazione col server")
                semaphore.signal()
            }
        }
    }
    class func loadProfile() -> Profile {
        print("Caricamento in corso...")
        semaphore.wait()
        print("Caricamento completato")
        semaphore.signal()
        return Profile()
    }
    class private func convertStringToData(string: String) -> Data? {
        if string == "empty" {
            let image = UIImage(named: "profile.png")
            return image?.jpegData(compressionQuality: 0.0)
        }
        return Data(base64Encoded: string)!
    }
    
}

struct Profile {
    let myProfile = PersistanceManager.retriveStat()
    var score: Int  {
        get {
            return Int(myProfile[0])
        }
    }
    var wins: Int {
        get {
            return Int(myProfile[1])
        }
    }
    var losses: Int {
        get {
            return Int(myProfile[3])
        }
    }
    var draws: Int {
        get {
            return Int(myProfile[2])
        }
    }
    var image: UIImage {
        get {
            let data =  PersistanceManager.retriveImage()
            return UIImage(data: data as! Data)!
        }
    }
    var gamerTag: String {
        get {
            return PersistanceManager.retriveGamerTag()!
        }
    }
}