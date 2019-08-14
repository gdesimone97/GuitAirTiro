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
        if let deviceList = session.showConnectedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(5))
        }
    }
    
    @IBAction func button2(_ sender: Any) {
        if let deviceList = session.showConnectedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(6))
        }
    }
    
    @IBAction func button3(_ sender: Any) {
        if let deviceList = session.showConnectedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(7))
        }
    }
    
    @IBAction func button4(_ sender: Any) {
        if let deviceList = session.showConnectedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(8))
        }
    }
    
    @IBAction func buttonSend(_ sender: Any) {
        if let deviceList = session.showConnectedDevices() {
            let messaggio = text.text as! String
            session.sendSignalGame(deviceList[0], signal: SignalCode.key1Pressed)
           // session.sendSignal(deviceList[0], message: UInt8(messaggio)!)
        }
    }
    
    
    
    @IBAction func button1Pressed(_ sender: Any) {
        if let deviceList = session.showConnectedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(11))
        }
    }
    
    @IBAction func button1ReleasedIn(_ sender: Any) {
        if let deviceList = session.showConnectedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(15))
        }
    }
    
    @IBAction func button2Pressed(_ sender: Any) {
        if let deviceList = session.showConnectedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(12))
        }
    }
    
    @IBAction func button2Released(_ sender: Any) {
        if let deviceList = session.showConnectedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(16))
        }
    }
    
    @IBAction func button3Pressed(_ sender: Any) {
        if let deviceList = session.showConnectedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(13))
        }
    }
    
    @IBAction func button3ReleasedIn(_ sender: Any) {
        if let deviceList = session.showConnectedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(17))
        }
    }
    
    @IBAction func button4Pressed(_ sender: Any) {
        if let deviceList = session.showConnectedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(14))
        }
    }
    
    @IBAction func button4ReleasedIn(_ sender: Any) {
        if let deviceList = session.showConnectedDevices() {
            session.sendSignal(deviceList[0], message: UInt8(18))
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
