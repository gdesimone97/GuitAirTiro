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
    
    let strClassic = "Acoustic Guitar Selected"
    let strElettric = "Electric Guitar Selected"
    
    //Session for comunicating with watch
    var session: WCSession!
    var sessionTv = SessionManager.share
    //func to set in the GameView
    var toCall: (()->Void)!
    
    //    Pairing status "led"
    @IBOutlet weak var deviceStatus: UIView!
    @IBOutlet var tvStatus: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    // Chords name displayed in home
    @IBOutlet weak var firstChordLabel: UILabel!
    @IBOutlet weak var secondChordLabel: UILabel!
    @IBOutlet weak var thirdChordLabel: UILabel!
    @IBOutlet weak var fourthChordLabel: UILabel!
    
    private var sessionTvConnected: Bool { get { return sessionTv.showConnectedDevices() != nil }}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        deviceStatus?.layer.cornerRadius = 8.34
        tvStatus?.layer.cornerRadius = 8.34
        
        if UserDefaults.getGuitar(forKey: GUITAR) == nil {
            UserDefaults.setGuitar(guitar: TypeOfGuitar.classic, forKey: GUITAR)
        }
        
        if userDefault.stringArray(forKey: AUDIO_FILE_NAME) == nil {
            let audioStandard = Array<String>(repeating: "A.wav", count: 4)
            userDefault.set(audioStandard, forKey: AUDIO_FILE_NAME)
        }
        
        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session.activate()
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
        let tvSettings = userDefault.integer(forKey: GAME_DEVICE_SETTINGS)
        if tvSettings == TvSettings.withWatch.rawValue {
            session.sendMessage(["payload": "start"], replyHandler: nil, errorHandler: nil)
        }
        if tvSettings == TvSettings.withOutWatch.rawValue {
            if let device = sessionTv.showConnectedDevices() {
                sessionTv.sendSignal(device[0], message: SignalCode.OpenGameWithOutWatch)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sessionTv.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let guitar = UserDefaults.getGuitar(forKey: GUITAR)
        DispatchQueue.main.async {
            self.inizializeGuitarLabel(guitar!)
        }
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
        
        let tv = userDefault.integer(forKey: GAME_DEVICE_SETTINGS)
        DispatchQueue.main.async {
            if self.session.isReachable {
                 self.deviceStatus?.backgroundColor = .green
            }
            else {
                self.deviceStatus.backgroundColor = .red
            }
            
            if self.sessionTvConnected {
                self.tvStatus.backgroundColor = .green
            }
            else {
                self.tvStatus.backgroundColor = .red
            }
            if tv == TvSettings.withWatch.rawValue && self.session.isReachable {
                self.playButton.isEnabled = true
            }
            else if tv == TvSettings.withOutWatch.rawValue && self.sessionTvConnected {
                self.playButton.isEnabled = true
            }
            else {
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
        //        guitarLabel.layer.frame = CGRect(x: 30.51, y: 583.67, width: 153.02, height: 47);
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
        let tv = userDefault.integer(forKey: GUITAR)
        if !session.isReachable{
            DispatchQueue.main.async {
                self.deviceStatus.backgroundColor = .red
                if tv == TvSettings.withWatch.rawValue {
                    self.playButton.isEnabled = false
                }
            }
        }
        else if session.isReachable{
            DispatchQueue.main.async {
                if tv == TvSettings.withWatch.rawValue {
                    self.playButton.isEnabled = true
                }
                self.deviceStatus.backgroundColor = .green
            }
        }
    }
}

extension ViewController: SessionManagerDelegate {
    func mexReceived(_ manager: SessionManager, didMessageReceived: Int) {
        return
    }
    
    
    func mexReceived(_ manager: SessionManager, didMessageReceived: Array<String>) {
        return
    }
    
    func peerFound(_ manger: SessionManager, peer: MCPeerID) {
        return
    }
    
    func nearPeerHasChangedState(_ manager: SessionManager, peer change: MCPeerID, connected: Int) {
        let guitar = UserDefaults.getGuitar(forKey: GUITAR)
        let tv = userDefault.integer(forKey: GAME_DEVICE_SETTINGS)
        if connected == 2 {
            if let device = sessionTv.showConnectedDevices() {
                if guitar == TypeOfGuitar.classic {
                    sessionTv.sendSignal(device[0], message: SignalCode.showAcousticGuitar)
                }
                else if guitar == TypeOfGuitar.electric {
                    sessionTv.sendSignal(device[0], message: SignalCode.showElectricGuitar)
                }
                let audio = userDefault.stringArray(forKey: AUDIO_FILE_NAME)!
                sessionTv.sendSignal(device[0], message: audio)
                DispatchQueue.main.async {
                    self.tvStatus.backgroundColor = .green
                    if tv == TvSettings.withOutWatch.rawValue {
                        self.playButton.isEnabled = true
                    }
                }
                
            }
        }
        if connected == 0 {
            DispatchQueue.main.async {
                self.tvStatus.backgroundColor = .red
                if tv == TvSettings.withOutWatch.rawValue {
                    self.playButton.isEnabled = false
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
