//
//  GuitarSelectedViewViewController.swift
//  Test1_SceneKit iOS
//
//  Created by Giuseppe De Simone on 05/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit

class GuitarSelectedViewController: UIViewController {
    
    let session = SessionManager.share
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var guitarLabel: UILabel!
    let guitar = UserDefaults.getGuitar(forKey: GUITAR)
    
    let classicGuitar = UIImage(named: "classic_guitar")
    let elettricGuitar = UIImage(named: "elettronic_guitar")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var arrayImages: Array<UIImage> = [classicGuitar!,elettricGuitar!]
        imageView.animationImages = arrayImages
         guitarLabel.text = selectGuitar(guitar!)
    }

    @IBAction func dxButton(_ sender: Any) {
        
    }
    @IBAction func sxButton(_ sender: Any) {
        
    }
    
    func selectGuitar(_ guitar: GuitarType) -> String {
        switch guitar {
        case .classic:
            return "classic"
        default:
            return "elettric"
        }
    }
    
}
