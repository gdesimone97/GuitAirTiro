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
    private static var enable = true
    
    static func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    static func createEmptyItem() {
        let context = getContext()
        guard enable == true else {print("Non puoi creare più di un record"); return}
        let statItem = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Stat
        
        statItem.draws = 0
        statItem.wins = 0
        statItem.image = nil
        statItem.gamerTag = ""
        statItem.losses = 0
        statItem.score = 0
        
        do {
            try context.save()
            enable = false
        } catch let error as NSError {
            print("Errore salvaggio: \(error.code)")
        }
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
