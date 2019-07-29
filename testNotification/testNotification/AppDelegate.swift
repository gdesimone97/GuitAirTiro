//
//  AppDelegate.swift
//  testNotification
//
//  Created by Giuseppe De Simone on 26/07/2019.
//  Copyright © 2019 Giuseppe De Simone. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Autorizzazioni
        notificationCenter.requestAuthorization(options: [.alert , .sound, .badge])
        { (granted, error) in /* funzionalità in base all'autorizzazione */ }
        notificationCenter.getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
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
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func notificationCategory() {
        let CATEGORY: String = "INVITATION"
        let gamerTag = "" /* Da completare */
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "Accept Invite", options: UNNotificationActionOptions.init(rawValue: 0))
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION", title: "Decline Invite", options: UNNotificationActionOptions(rawValue: 0))
        let inviteCategory = UNNotificationCategory(identifier: CATEGORY, actions: [acceptAction,declineAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        notificationCenter.setNotificationCategories([inviteCategory])
        
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
    
}
