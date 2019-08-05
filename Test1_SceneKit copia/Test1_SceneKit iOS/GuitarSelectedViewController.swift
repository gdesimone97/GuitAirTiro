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
    let guitar = UserDefaults.getGuitar(forKey: GUITAR)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guitarLabel.text = selectGuitar(guitar!)
        if let device = session.showConncetedDevices() {
            if guitar == TypeOfGuitar.classic {
                session.sendSignal(device[0], message: SignalCode.showElectricGuitar)
            }
            else if guitar == TypeOfGuitar.elettric {
                session.sendSignal(device[0], message: SignalCode.showAcousticGuitar)
            }
        }
    }
    
    @IBAction func dxButton(_ sender: Any) {
        if let device = session.showConncetedDevices() {
            if guitar == TypeOfGuitar.classic {
                session.sendSignal(device[0], message: SignalCode.showElectricGuitar)
            }
            else if guitar == TypeOfGuitar.elettric {
                session.sendSignal(device[0], message: SignalCode.showAcousticGuitar)
            }
        }
    }
    @IBAction func sxButton(_ sender: Any) {
        if let device = session.showConncetedDevices() {
            if guitar == TypeOfGuitar.classic {
                session.sendSignal(device[0], message: SignalCode.showElectricGuitar)
            }
            else if guitar == TypeOfGuitar.elettric {
                session.sendSignal(device[0], message: SignalCode.showAcousticGuitar)
            }
        }
    }
    
    
    
     override func viewDidDisappear(_ animated: Bool) {
        var guitar = selectGuitar(guitarLabel.text!)
        UserDefaults.setGuitar(guitar: guitar!, forKey: GUITAR)
    }
    
    
    func selectGuitar(_ guitar: TypeOfGuitar) -> String {
        switch guitar {
        case .classic:
            return "classic"
        case .elettric:
            return "electric"
        default:
            break
        }
    }
    
    func selectGuitar(_ guitar: String) -> TypeOfGuitar? {
        switch guitar {
        case "classic":
            return .classic
        case "electric":
            return .elettric
        default:
            return nil
        }
    }
    
}
