//
//  GameViewController.swift
//  tvConnectivity tvOS
//
//  Created by Giuseppe De Simone on 24/07/2019.
//  Copyright © 2019 Giuseppe De Simone. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    var session = SessionManager()
    var i = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
        i = 0
    }
    
}

extension GameViewController: SessionManagerDelegate {
    func peerFound(_ manger: SessionManager, peer: MCPeerID) {
        
      try! session.invitePeer(invite: peer)
    }
    
    func nearPeerHasChangedState(_ manager: SessionManager,peer: MCPeerID, connected state: Bool) {
        print("boh")
    }
    
    func mexReceived(_ manager: SessionManager, didMessaggeReceived: UInt8) {        print("Messaggio: \(didMessaggeReceived)")
    } 
}
