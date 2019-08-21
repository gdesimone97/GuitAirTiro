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
    
    static func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    static func createEmptyItem() {
        let context = getContext()
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
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        var number = 0
        do {
             number = try context.count(for: fetchRequest)
        } catch { print("Errore recupero oggetto") }
        if number == 0 { return true }
        else { return false }
    }
    private static func getItem() -> Stat? {
        let context = getContext()
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
    
    static func retriveImage() -> NSData? {
        return getItem()?.image
    }
    
    static func retriveGamerTag() -> String? {
        return getItem()?.gamerTag
    }
    
    static func retriveStat() -> [Int64] {
        let item = getItem()
        var stat = Array<Int64>(repeating: 0, count: 4)
        stat[0] = item?.score ?? 0
        stat[1] = item?.wins ?? 0
        stat[2] = item?.draws ?? 0
        stat[3] = item?.losses ?? 0
        return stat
    }
    
    static func UploadStat(wins: Int?,loose: Int?,draws: Int?,score: Int?,image: Data?,gamerTag: String?) {
        let context = getContext()
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
            if loose != nil {
                item.losses = Int64(loose!)
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
