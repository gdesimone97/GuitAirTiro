//
//  SessionManager.swift
//  iGuitar WatchKit Extension
//
//  Created by Giuseppe De Simone on 11/07/2019.
//  Copyright © 2019 Giuseppe De Simone. All rights reserved.
//

import Foundation
import WatchConnectivity

class SessionManagerWatch: NSObject,WCSessionDelegate {
    
    private let session = WCSession.default
    
    var connectionStatus: Bool = false
    
    var sessionStatus: WCSessionActivationState {
        get {
            return session.activationState
        }
    }
    
    static var share = SessionManagerWatch()
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            print("Watch - Conessione supportata")
            session.delegate = self
            session.activate()
        }
        else {
            print("Watch - Connessione non supportata")
        }
        sleep(2)
        connectionStatus = checkConnection()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if (activationState == WCSessionActivationState.activated){
            print("Watch - Connessione attivata con successo")
        }
        else {
            print("Watch - Connessione conclusa con successo")
        }
    }
    

    func checkConnection() -> Bool{
        
        guard self.sessionStatus == WCSessionActivationState.activated else {
            print("Watch - Connessione non disponibile")
            return false
        }
        guard self.session.isReachable else {
            if  self.session.iOSDeviceNeedsUnlockAfterRebootForReachability {
                print("Sblocca iphone")
            }
            return false
        }
        return true
    }
    
    func sendMessage(_ message: [String: Any]){
        if checkConnection() {
            print("Messaggio inviato")
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
        else {
            print("Messaggio non inviato")
        }
    }
    
    
     class func reconnect(){
        self.share = SessionManagerWatch()
    }
}
