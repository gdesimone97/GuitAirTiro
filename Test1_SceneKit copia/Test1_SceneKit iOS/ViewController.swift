//
//  ViewController.swift
//  LetsPlayStoryboards
//
//  Created by Christian Marino on 14/07/2019.
//  Copyright © 2019 Christian Marino. All rights reserved.
//

import UIKit
import WatchConnectivity
import MultipeerConnectivity

class ViewController: UIViewController{
    
    @IBOutlet var guitarLabel: UILabel!
    
    var userDataChords: Array<String>?
    
    let strClassic = "Classic Guitar Selected"
    let strElettric = "Electric Guitar Selected"
    
    //Session for comunicating with watch
    var session: WCSession!
    var sessionTv = SessionManager.share
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
        sessionTv.delegate = self
        // Updating of chords label
        //fourthChordLabel?.text = "Gm"
        
        if let guitar = UserDefaults.getGuitar(forKey: GUITAR) { }
        else {
            UserDefaults.setGuitar(guitar: TypeOfGuitar.classic, forKey: GUITAR)
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
        if let device = sessionTv.showConncetedDevices() {
            sessionTv.sendSignal(device[0], message: SignalCode.openGame)
        }
    }
    
     override func viewWillAppear(_ animated: Bool) {
        let guitar = UserDefaults.getGuitar(forKey: GUITAR)
        DispatchQueue.main.async {
            self.inizializeGuitarLabel(guitar!)
        }
        
        let user = userDefault.integer(forKey: GAME_DEVICE_SETTINGS)
        if user == 0 {
            if WCSession.isSupported() && session == nil {
                session = WCSession.default
                session!.delegate = self
                session.activate()
            }
        }
        else if user == 1 {
            session = nil
        }
    }
    
     override func viewDidDisappear(_ animated: Bool) {
        if let device = sessionTv.showConncetedDevices() {
            sessionTv.sendSignal(device[0], message: SignalCode.closeGame)
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
        
        
        DispatchQueue.main.async {
            if self.session != nil && self.session.isReachable{
                self.playButton.isEnabled = true
                self.deviceStatus?.backgroundColor = .green
            }
            else{
                self.deviceStatus?.backgroundColor = .red
                self.playButton.isEnabled = false
            }
        }
        
        
        if let testGuitar = UserDefaults.getGuitar(forKey: GUITAR) {
            inizializeGuitarLabel(testGuitar)
        }
        else {
            UserDefaults.setGuitar(guitar: TypeOfGuitar.classic, forKey: GUITAR)
            inizializeGuitarLabel(TypeOfGuitar.classic)
        }
        setLabelBoard()
    }
    
    func inizializeGuitarLabel (_ guitar: TypeOfGuitar) {
        switch guitar {
        case .electric:
            guitarLabel.text = strElettric
            break
        case .classic:
            guitarLabel.text = strClassic
            break
        default:
            break;
        }
    }
    
    func setLabelBoard() {
        guitarLabel.layer.frame = CGRect(x: 30.51, y: 583.67, width: 153.02, height: 47);
        guitarLabel.layer.backgroundColor = UIColor(red: 0.28, green: 0.32, blue: 0.37, alpha: 1).cgColor;
        guitarLabel.layer.cornerRadius = 8;
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

extension ViewController: SessionManagerDelegate {
    func peerFound(_ manger: SessionManager, peer: MCPeerID) {
        return
    }
    
    func nearPeerHasChangedState(_ manager: SessionManager, peer change: MCPeerID, connected: Int) {
        let guitar = UserDefaults.getGuitar(forKey: GUITAR)
        if connected == 2 {
            if let device = sessionTv.showConncetedDevices() {
                if guitar == TypeOfGuitar.classic {
                    sessionTv.sendSignal(device[0], message: SignalCode.showAcousticGuitar)
                }
                else if guitar == TypeOfGuitar.electric {
                    sessionTv.sendSignal(device[0], message: SignalCode.showElectricGuitar)
                }
            }
        }
    }
    
    func mexReceived(_ manager: SessionManager, didMessageReceived: SignalCode) {
        return
    }
    
    func peerLost(_ manager: SessionManager, peer lost: MCPeerID) {
        return
    }
    
    
}
