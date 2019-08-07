//
//  AppDelegate.swift
//  LetsPlayStoryboards
//
//  Created by Christian Marino on 14/07/2019.
//  Copyright © 2019 Christian Marino. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity
import  UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let udef = UserDefaults.standard;
    let NOTATION_KEY = "PreferredNotation";
    let notificationCenter = UNUserNotificationCenter.current()
    let CATEGORY: String = "INVITATION"
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        //Se non è inizializzata la notazione preferita
        
        
        
        if udef.string(forKey: NOTATION_KEY ) != nil{
            
        }else{
            
            if(udef.array(forKey: USER_DEFAULT_KEY_STRING) == nil ){
                udef.setValue(["La","La","La","La"],forKey: USER_DEFAULT_KEY_STRING);
            }
            
            udef.set("IT", forKey: NOTATION_KEY);
        }
        
        // *** Notifiche ***
        // Autorizzazioni
        notificationCenter.requestAuthorization(options: [.alert , .sound, .providesAppNotificationSettings]) { (granted, error) in /* funzionalità in base all'autorizzazione */ }
        notificationCenter.getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                // Registrazione per le push notification
                application.registerForRemoteNotifications()
            }
            self.notificationCategory()
            if settings.alertSetting == .enabled {
                /* Fai qualcosa se hai i permessi per l'allert */
            }
            else { /* Fai altro */ }
        }
        
        // Fine autorizzazioni
        notificationCenter.delegate = self
        
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if let viewControllers = self.window?.rootViewController?.children{
            for controller in viewControllers{
                if controller.title == "MainWindowController"{
                    let viewController = controller as! ViewController
                    if viewController.session != nil {
                        viewController.session.sendMessage(["payload": "stop"], replyHandler: nil, errorHandler: nil)
                    }
                }
            }
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        var session: WCSession?
        
        if let viewControllers = self.window?.rootViewController?.children{
            for controller in viewControllers{
                if controller.title == "MainWindowController"{
                    let viewController = controller as! ViewController
                    session = viewController.session
                }
            }
        }
        
        if let currController = application.keyWindow?.rootViewController?.presentedViewController{
            if currController.title == "GameModeViewController"{
                if session != nil{
                    session!.sendMessage(["payload": "start"], replyHandler: nil, errorHandler: nil)
                }
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        if let viewControllers = self.window?.rootViewController?.children{
            for controller in viewControllers{
                if controller.title == "MainWindowController"{
                    let viewController = controller as! ViewController
                    viewController.session.sendMessage(["payload": "stop"], replyHandler: nil, errorHandler: nil)
                }
            }
        }   
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "LetsPlayStoryboards")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func notificationCategory() {
        
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "Accept Invite", options: UNNotificationActionOptions.init(rawValue: 0))
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION", title: "Decline Invite", options: UNNotificationActionOptions(rawValue: 0))
        let inviteCategory = UNNotificationCategory(identifier: CATEGORY, actions: [acceptAction,declineAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        notificationCenter.setNotificationCategories([inviteCategory])
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push notification non attive")
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
     func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let gamerTag = userInfo["GAMERTAG"]
        switch response.actionIdentifier {
        case "ACCEPT_ACTION":
            print("invito accettato")
            /* fai qualcosa */
        case "DECLINE_ACTION":
            print("invito declinato")
            /* fai qualcosa */
        default:
            break
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.content.categoryIdentifier == CATEGORY {
            completionHandler([.alert,.sound])
            return
        }
        completionHandler(.alert)
    }
}


