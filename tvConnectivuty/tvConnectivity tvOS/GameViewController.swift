//
//  GameViewController.swift
//  tvConnectivity tvOS
//
//  Created by Giuseppe De Simone on 24/07/2019.
//  Copyright © 2019 Giuseppe De Simone. All rights reserved.
//

import UIKit


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
    func nearPeerHasChangedState(_ manager: SessionManager,peer: String, connected state: Bool) {
        let peerList = session.showConncetedDevices()
        DispatchQueue.main.async {
        self.label.text = ""
        }
        for device in peerList {
            DispatchQueue.main.async {
            self.label.text = self.label.text! + device + "\n"
            }
        }
        print("cambio stato")
    }
    
    func mexReceived(_ manager: SessionManager, didMessaggeReceived: Data) {
        i += 1
        print("\(i)")
    }
    
}
