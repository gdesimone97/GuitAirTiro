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
    
    @IBOutlet weak var swipeImage: UIImageView!
    
    // swipe variables
    @IBOutlet var leftSwipe: UISwipeGestureRecognizer!
    @IBOutlet var rightSwipe: UISwipeGestureRecognizer!
    
    let electricImage : UIImage = (UIImage(named: "electric"))!
    let acousticImage : UIImage = (UIImage(named: "acoustic"))!
    
    
    
    // swipeImage movement
    func moveSwipeImageLeft(){
        UIView.animate(withDuration: 1.5, animations: {
            self.swipeImage.center.x -= 60.0
        }, completion: {finished in self.moveSwipeImageRight()} )
    }
    
    func moveSwipeImageRight(){
        UIView.animate(withDuration: 1.5, animations: {
            self.swipeImage.center.x += 60.0
        }, completion: {finished in self.moveSwipeImageLeft()} )
    }

    override func viewWillAppear(_ animated: Bool) {
       self.swipeImage.center.x -= 30
       self.moveSwipeImageRight()
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        
        //swipe directions
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        rightSwipe.direction = UISwipeGestureRecognizer.Direction.right
        
        let guitar = UserDefaults.getGuitar(forKey: GUITAR)
        switch guitar {
        case .classic?:
            imageView.image = acousticImage
            guitarLabel!.text = "ACOUSTIC"
        case .electric?:
            imageView.image = electricImage
            guitarLabel!.text = "ELECTRIC"
        default:
            imageView.image = acousticImage
            guitarLabel!.text = "ACOUSTIC"
        }
        

    }
    
    @IBAction func leftSwipePerformed(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            let guitar = UserDefaults.getGuitar(forKey: GUITAR)
                    if guitar == TypeOfGuitar.classic {
                        if let device = session.showConnectedDevices() {
                            session.sendSignal(device[0], message: SignalCode.showElectricGuitar)
                        }
                        UserDefaults.setGuitar(guitar: TypeOfGuitar.electric, forKey: GUITAR)
                        imageView!.image = electricImage
                        guitarLabel!.text = "ELECTRIC"
                    }
                    else if guitar == TypeOfGuitar.electric {
                        if let device = session.showConnectedDevices() {
                            session.sendSignal(device[0], message: SignalCode.showAcousticGuitar)
                        }
                        UserDefaults.setGuitar(guitar: TypeOfGuitar.classic, forKey: GUITAR)
                        imageView!.image = acousticImage
                        guitarLabel!.text = "ACOUSTIC"
                    }
                }
            }
    
    
    
    @IBAction func rightSwipePerformed(_ sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
                    let guitar = UserDefaults.getGuitar(forKey: GUITAR)
                        if guitar == TypeOfGuitar.classic {
                            if let device = session.showConnectedDevices() {
                                session.sendSignal(device[0], message: SignalCode.showElectricGuitar)
                            }
                            UserDefaults.setGuitar(guitar: TypeOfGuitar.electric, forKey: GUITAR)
                            imageView!.image = electricImage
                            guitarLabel!.text = "ELECTRIC"
                        }
                        else if guitar == TypeOfGuitar.electric {
                            if let device = session.showConnectedDevices() {
                                session.sendSignal(device[0], message: SignalCode.showAcousticGuitar)
                            }
                            UserDefaults.setGuitar(guitar: TypeOfGuitar.classic, forKey: GUITAR)
                            imageView!.image = acousticImage
                            guitarLabel!.text = "ACOUSTIC"
                        }
            
            
        }
    }
    

}
