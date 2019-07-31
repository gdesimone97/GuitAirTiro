//
//  ViewController.swift
//  LetsPlayStoryboards
//
//  Created by Christian Marino on 14/07/2019.
//  Copyright © 2019 Christian Marino. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController{

    let userDefault = UserDefaults.standard
    let USER_DEFAULT_KEY_STRING = "chords_string"
    var userDataChords: Array<String>?
    
    //Session for comunicating with watch
    var session: WCSession!
    
    //func to set in the GameView
    var toCall: (()->Void)!

//    Pairing status "led"
    @IBOutlet weak var deviceStatus: UIView!

    @IBOutlet weak var playButton: UIButton!
    
    // Chords name displayed in home
    @IBOutlet weak var firstChordLabel: UILabel!
    @IBOutlet weak var secondChordLabel: UILabel!
    @IBOutlet weak var thirdChordLabel: UILabel!
    @IBOutlet weak var fourthChordLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        deviceStatus?.layer.cornerRadius = 8.34

        // Updating of chords label
        //fourthChordLabel?.text = "Gm"

        if WCSession.isSupported(){
            session = WCSession.default
            session!.delegate = self
            session.activate()
        }
        else{
            print("Could not activate session")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showGame":
            let dstView = segue.destination as! GameModeViewController
            dstView.sessionDelegate = self
        default:
            print(#function)
        }
    }

//    Send start message to Watch when "play" button is pressed
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if session != nil {
            session.sendMessage(["payload": "start"], replyHandler: nil, errorHandler: nil)
            
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if let testUserDefault = userDefault.array(forKey: USER_DEFAULT_KEY_STRING) {
            var userData = testUserDefault as! Array<String>
            userDataChords = userData
            DispatchQueue.main.async {
            self.firstChordLabel.text = userData [0]
            self.secondChordLabel.text = userData [1]
            self.thirdChordLabel.text = userData [2]
            self.fourthChordLabel.text = userData [3]
            }
        }
        else {
            firstChordLabel.text = ""
            secondChordLabel.text = ""
            thirdChordLabel.text = ""
            fourthChordLabel.text = ""
        }
        
        
        if session.isReachable{
            playButton.isEnabled = true
            deviceStatus?.backgroundColor = .green
        }
        else{
            deviceStatus?.backgroundColor = .red
            playButton.isEnabled = false
        }
    }
}

extension ViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
       /*
        if !session.isPaired{
            deviceStatus?.backgroundColor = .red
            return
        }
        switch activationState{
        case WCSessionActivationState.activated:
            deviceStatus?.backgroundColor = .green
        case WCSessionActivationState.inactive, WCSessionActivationState.notActivated:
            deviceStatus?.backgroundColor = .yellow
        default:
            deviceStatus?.backgroundColor = .red
        }
 */
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        /*
        if !session.isPaired{
            deviceStatus?.backgroundColor = .red
            return
        }
        deviceStatus?.backgroundColor = .yellow
 */
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        /*
        if !session.isPaired{
            deviceStatus?.backgroundColor = .red
            return
        }
        deviceStatus?.backgroundColor = .yellow
 */
    }
    

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]){
        guard message["payload"] as! String == "1" else{
            print("Payload non è 1")
            return
        }
        toCall()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if !session.isReachable{
            DispatchQueue.main.async {
                self.deviceStatus.backgroundColor = .red
                self.playButton.isEnabled = false
            }
        }
        else if session.isReachable{
            DispatchQueue.main.async {
                self.playButton.isEnabled = true
                self.deviceStatus.backgroundColor = .green
            }
        }
    }
}
