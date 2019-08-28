//
//  PersistanceManager.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 21/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PersistanceManager {
    static let entityName = "Stat"
    static let entityGame = "Games"
    static var mycontext: NSManagedObjectContext! {
        get {
            return context
        }
        set {
            context = newValue
        }
    }
    private static var context: NSManagedObjectContext!
    //    static func getContext() -> NSManagedObjectContext {
    //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //        return appDelegate.persistentContainer.viewContext
    //    }
    
    private static func checkRecordGames()->Bool{
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityGame)
        var number = 0
        do {
            number = try context.count(for: fetchRequest)
        } catch { print("Errore recupero oggetto") }
        if number == 0 { return true }
        else { return false }
    }
    
    static func createEmptyGames(){
        guard checkRecordGames() == true else { print("No record creato games"); return }
        print("Record creato games")
        let gameItem = NSEntityDescription.insertNewObject(forEntityName: entityGame, into: context) as! Games
        gameItem.progrGamesSerialized = nil
        gameItem.endedGamesSerialized = nil
        gameItem.last_server_read = Date.distantPast as NSDate
        do {
            try context.save()
        } catch let error as NSError {
            print("Errore salvaggio game: \(error.code)")
        }
    }
    
    static func uploadGame(progrMatches: Data?,endedMatches: Data?,lastRead: Date?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityGame)
        fetchRequest.fetchLimit = 1
        do {
            let result = try context.fetch(fetchRequest) as! [Games]
            let item = result[0]
            if progrMatches != nil {
                item.progrGamesSerialized = progrMatches! as NSData
            }
            if endedMatches != nil {
                item.endedGamesSerialized = endedMatches! as NSData
            }
            if lastRead != nil {
                item.last_server_read = lastRead! as NSDate
            }
        } catch {
            print("Aggiornamento fallito Games")
        }
        do {
            try context.save()
        } catch let error as NSError {
            print("Errore salvaggio: \(error.code) Games")
        }
    }
    
    static func uploadLastRead(lastRead: Date) {
        uploadGame(progrMatches: nil, endedMatches: nil, lastRead: lastRead)
    }
    
    static func retriveLastServerRead() -> Date {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityGame)
        fetchRequest.fetchLimit = 1
        do {
            let result = try context.fetch(fetchRequest) as! [Games]
            let item = result[0]
            return item.last_server_read! as Date
        } catch { print("Errore recupero oggetto")
            return Date.distantPast
        }
    }
    
    static func retriveGame() -> (prog: Dictionary<String,Array<Dictionary<String,String>>>,ended: Dictionary<String,Array<Dictionary<String,String>>>)? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityGame)
        fetchRequest.fetchLimit = 1
        do {
            let result = try context.fetch(fetchRequest) as! [Games]
            let item = result[0]
            let prog = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(item.progrGamesSerialized! as Data) as! Dictionary<String,Array<Dictionary<String,String>>>
            let ended = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(item.endedGamesSerialized! as Data) as! Dictionary<String,Array<Dictionary<String,String>>>
            return (prog: prog,ended: ended)
        } catch { print("Errore recupero oggetto")
            return nil
        }
    }
    
    static func createEmptyItem() {
        //let context = getContext()
        guard checkRecord() == true else { print("No record creato"); return }
        print("Record creato")
        let statItem = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Stat
        
        statItem.draws = 0
        statItem.wins = 0
        statItem.image = nil
        statItem.gamerTag = "GAMERTAG"
        statItem.losses = 0
        statItem.score = 0
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Errore salvaggio: \(error.code)")
        }
    }
    private static func checkRecord() -> Bool {
        //let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var number = 0
        do {
            number = try context.count(for: fetchRequest)
        } catch { print("Errore recupero oggetto") }
        if number == 0 { return true }
        else { return false }
    }
    private static func getItem() -> Stat? {
        //let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.fetchLimit = 1
        do {
            let result = try context.fetch(fetchRequest) as! [Stat]
            let item = result[0]
            return item
        } catch { print("Errore recupero oggetto")
            return nil
        }
        
    }
    
    static func uploadImage(image: UIImage) {
        PersistanceManager.UploadStat(score: nil, wins: nil, draws: nil, losses: nil, image: image.jpegData(compressionQuality: 0.0), gamerTag: nil)
    }
    
    static func retriveImage() -> NSData? {
        return getItem()?.image
    }
    
    static func retriveGamerTag() -> String? {
        return getItem()?.gamerTag
    }
    
    static func retriveStat() -> [Int64] {
        let item = getItem()
        var stat = Array<Int64>(repeating: 0, count: 4)
        stat[0] = item?.score ?? -1
        stat[1] = item?.wins ?? -1
        stat[2] = item?.draws ?? -1
        stat[3] = item?.losses ?? -1
        return stat
    }
    
    static func UploadStat(score: Int?,wins: Int?,draws: Int?,losses: Int?,image: Data?,gamerTag: String?) {
        //let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.fetchLimit = 1
        do {
            let result = try context.fetch(fetchRequest) as! [Stat]
            let item = result[0]
            if wins != nil {
                item.wins = Int64(wins!)
            }
            if draws != nil {
                item.draws = Int64(draws!)
            }
            if losses != nil {
                item.losses = Int64(losses!)
            }
            if score != nil {
                item.score = Int64(score!)
            }
            if gamerTag != nil {
                item.gamerTag = gamerTag
            }
            if image != nil {
                let nsdata = NSData(data: image!)
                item.image = nsdata
            }
        } catch {
            print("Aggiornamento fallito")
        }
        do {
            try context.save()
        } catch let error as NSError {
            print("Errore salvaggio: \(error.code)")
        }
    }
}
