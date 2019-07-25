//
//  GameViewController.swift
//  tvConnectivity iOS
//
//  Created by Giuseppe De Simone on 24/07/2019.
//  Copyright © 2019 Giuseppe De Simone. All rights reserved.
//

import UIKit

class GameViewControllerPhone: UIViewController {

    @IBOutlet var label: UILabel!
    var session = SessionManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        session.delegate = self
        label.text = "nulla"
    }
    
    @IBAction func controller(_ sender: Any) {
        
    }
    @IBAction func button(_ sender: Any) {
        var deviceList = session.showConncetedDevices()
        session.sendSignal(deviceList[0], message: 1)
    }
}

extension GameViewControllerPhone: SessionManagerDelegate {
    
    func nearPeerHasChangedState(_ manager: SessionManager, peer: String, connected state: Bool) {
        DispatchQueue.main.async {
        if state {
            self.label.text = "conneted"
        }
        else {
            self.label.text = "disconnected"
        }
        }
    }
}
