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
    var session = SessionManager.share
    var i = 0
    var peer: MCPeerID?
    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
        i = 0
    }
    
}

extension GameViewController: SessionManagerDelegate {
    func peerFound(_ manger: SessionManager, peer: MCPeerID) {
        self.peer = peer
        try! session.invitePeer(invite: peer)
    }
    
    func nearPeerHasChangedState(_ manager: SessionManager,peer: MCPeerID, connected state: Bool) {
        print("boh")
    }
    
    func mexReceived(_ manager: SessionManager,peer: MCPeerID, didMessaggeReceived: UInt8) {        print("Messaggio: \(didMessaggeReceived)")
        session.sendSignal(peer, message: 0)
    }
}
