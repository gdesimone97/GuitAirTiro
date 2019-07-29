//
//  GameViewController.swift
//  tvConnectivity iOS
//
//  Created by Giuseppe De Simone on 24/07/2019.
//  Copyright © 2019 Giuseppe De Simone. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameViewControllerPhone: UIViewController {
    
    @IBOutlet var label: UILabel!
    var session = SessionManager.share
    var i: UInt8 = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
        label.text = "nulla"
    }
    
    @IBAction func controller(_ sender: Any) {
        session.disconnectedPeer()
    }
    
    @IBAction func button(_ sender: Any) {
        if let deviceList = session.showConncetedDevices() {
            session.sendSignal(deviceList[0], message: 2)
        }
    }
    
    @IBAction func button2(_ sender: Any) {
        if let deviceList = session.showConncetedDevices() {
            session.sendSignal(deviceList[0], message: 5)
        }
    } 
}

extension GameViewControllerPhone: SessionManagerDelegate {
    
    func peerFound(_ manger: SessionManager, peer: MCPeerID) {
        print("peer trovato: \(peer)")
    }
    
    func nearPeerHasChangedState(_ manager: SessionManager, peer: MCPeerID, connected state: Bool) {
        DispatchQueue.main.async {
            if state {
                self.label.text = "conneted"
            }
            else {
                self.label.text = "disconnected"
            }
        }
    }
    
    func mexReceived(_ manager: SessionManager, didMessaggeReceived: UInt8) {
        print("Messaggio ricevuto: \(didMessaggeReceived)")
    }
    
}
