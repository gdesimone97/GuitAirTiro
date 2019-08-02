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
    
    @IBOutlet var text: UITextField!
    @IBOutlet var label: UILabel!
    
    var session = SessionManager.share
    var i: UInt8 = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
        label.text = "nulla"
    }
    
    @IBAction func button1(_ sender: Any) {
        if let deviceList = session.showConncetedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(5))
        }
    }
    
    @IBAction func button2(_ sender: Any) {
        if let deviceList = session.showConncetedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(6))
        }
    }
    
    @IBAction func button3(_ sender: Any) {
        if let deviceList = session.showConncetedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(7))
        }
    }
    
    @IBAction func button4(_ sender: Any) {
        if let deviceList = session.showConncetedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(8))
        }
    }
    
    @IBAction func buttonSend(_ sender: Any) {
        if let deviceList = session.showConncetedDevices() {
            let messaggio = text.text as! String
            session.sendSignal(deviceList[0], message: UInt8(messaggio)!)
           // session.sendSignal(deviceList[0], message: UInt8(messaggio)!)
        }
    } 
}

extension GameViewControllerPhone: SessionManagerDelegate {
    func mexReceived(_ manager: SessionManager, didMessageReceived: SignalCode) {
        print("Messaggio ricevuto: \(didMessageReceived)")
    }
    
    func peerLost(_ manager: SessionManager, peer lost: MCPeerID) {
        return
    }
    
    
    func peerFound(_ manger: SessionManager, peer: MCPeerID) {
        print("peer trovato: \(peer)")
    }
    
    func nearPeerHasChangedState(_ manager: SessionManager, peer change: MCPeerID, connected: Int)  {
        DispatchQueue.main.async {
            if connected == 2 {
                self.label.text = "conneted"
            }
            else {
                self.label.text = "disconnected"
            }
        }
    }
    
}
