//
//  GuitarSelectedViewViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 05/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GuitarSelectedViewController: UIViewController {
    
    let session = SessionManager.share
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var guitarLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func dxButton(_ sender: Any) {
        let guitar = UserDefaults.getGuitar(forKey: GUITAR)
            if guitar == TypeOfGuitar.classic {
                if let device = session.showConncetedDevices() {
                    session.sendSignal(device[0], message: SignalCode.showElectricGuitar)
                }
                UserDefaults.setGuitar(guitar: TypeOfGuitar.electric, forKey: GUITAR)
            }
            else if guitar == TypeOfGuitar.electric {
                if let device = session.showConncetedDevices() {
                    session.sendSignal(device[0], message: SignalCode.showAcousticGuitar)
                }
                UserDefaults.setGuitar(guitar: TypeOfGuitar.classic, forKey: GUITAR)
            }
    }
    @IBAction func sxButton(_ sender: Any) {
        let guitar = UserDefaults.getGuitar(forKey: GUITAR)
        if guitar == TypeOfGuitar.classic {
            if let device = session.showConncetedDevices() {
                session.sendSignal(device[0], message: SignalCode.showElectricGuitar)
            }
            UserDefaults.setGuitar(guitar: TypeOfGuitar.electric, forKey: GUITAR)
        }
        else if guitar == TypeOfGuitar.electric {
            if let device = session.showConncetedDevices() {
                session.sendSignal(device[0], message: SignalCode.showAcousticGuitar)
            }
            UserDefaults.setGuitar(guitar: TypeOfGuitar.classic, forKey: GUITAR)
        }
    }
}
