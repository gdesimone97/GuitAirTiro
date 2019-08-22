//
//  GameModeViewController.swift
//  LetsPlayStoryboards
//
//  Created by Francesco Chiarello on 16/07/2019.
//  Copyright © 2019 Christian Marino. All rights reserved.
//

import UIKit
import WatchConnectivity
import AudioKit
import MultipeerConnectivity
import CoreMotion

class GameModeViewController: UIViewController {
    
    var sessionDelegate: ViewController!
    let sessionTv = SessionManager.share
    var motionManager: CMMotionManager!
    
    var oldAttitude: Double! = 0.00
    var newAttitude: Double! = 0.00
    
    var device: MCPeerID?
    var buttonActionRedInside: (() -> Void)?
    var buttonActionRedExit: (() -> Void)?
    var buttonActionRedDown: (() -> Void)?
    var buttonActionBlueInside: (() -> Void)?
    var buttonActionBlueExit: (() -> Void)?
    var buttonActionBlueDown: (() -> Void)?
    var buttonActionGreenInside: (() -> Void)?
    var buttonActionGreenExit: (() -> Void)?
    var buttonActionGreenDown: (() -> Void)?
    var buttonActionPinkInside: (() -> Void)?
    var buttonActionPinkExit: (() -> Void)?
    var buttonActionPinkDown: (() -> Void)?
    
    // Labels shown in game mode, each label is associated with a button
    @IBOutlet weak var redButtonChord: UILabel!
    @IBOutlet weak var blueButtonChord: UILabel!
    @IBOutlet weak var greenButtonChord: UILabel!
    @IBOutlet weak var pinkButtonChord: UILabel!
    
    //    Buttons
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var roseButton: UIButton!
    
    /**********GUITAR-RELATED VARIABLES*****************/
    var guitar11: Guitar?
    var guitar21: Guitar?
    var guitar31: Guitar?
    var guitar41: Guitar?
    var guitar12: Guitar?
    var guitar22: Guitar?
    var guitar32: Guitar?
    var guitar42: Guitar?
    
    var flag1 = false
    var flag2 = false
    var flag3 = false
    var flag4 = false
    
    let itaEnMap = [
        "Do": "C",
        "Dom": "Cm",
        "Re": "D",
        "Rem": "Dm",
        "Mi": "E",
        "Mim": "Em",
        "Fa": "F",
        "Fam": "Fm",
        "Sol": "G",
        "Solm": "Gm",
        "La": "A",
        "Lam": "Am",
        "Si": "B",
        "Sim": "Bm",
    ]
    
    var toPlay: [String]!
    
    /**************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //        Label rotation in game mode
        
        let tv = userDefault.integer(forKey: GAME_DEVICE_SETTINGS)
        
        switch tv {
        case TvSettings.withWatch.rawValue:
            self.buttonActionRedInside = self.playNothing
            self.buttonActionRedDown = self.playNothing
            self.buttonActionRedExit = self.playNothing
            self.buttonActionBlueInside = self.playNothing
            self.buttonActionBlueDown = self.playNothing
            self.buttonActionBlueExit = self.playNothing
            self.buttonActionGreenInside = self.playNothing
            self.buttonActionGreenDown = self.playNothing
            self.buttonActionGreenExit = self.playNothing
            self.buttonActionPinkInside = self.playNothing
            self.buttonActionPinkDown = self.playNothing
            self.buttonActionPinkExit = self.playNothing
        case TvSettings.withOutWatch.rawValue:
            self.buttonActionRedInside = self.playRedInside
            self.buttonActionRedDown = self.playRedDown
            self.buttonActionRedExit = self.playRedExit
            self.buttonActionBlueInside = self.playBlueInside
            self.buttonActionBlueDown = self.playBlueDown
            self.buttonActionBlueExit = self.playBlueExit
            self.buttonActionGreenInside = self.playGreenInside
            self.buttonActionGreenDown = self.playGreenDown
            self.buttonActionGreenExit = self.playGreenExit
            self.buttonActionPinkInside = self.playPinkInside
            self.buttonActionPinkDown = self.playPinkDown
            self.buttonActionPinkExit = self.playPinkExit
            self.device = self.sessionTv.showConnectedDevices()![0]
        default:
            break
        }
        
        redButtonChord?.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        blueButtonChord?.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        greenButtonChord?.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        pinkButtonChord?.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        
        sessionTv.delegateGame = self
        
        
        if sessionDelegate != nil {
            if let device = sessionTv.showConnectedDevices() {
                let tv = userDefault.integer(forKey: GAME_DEVICE_SETTINGS)
                if tv == TvSettings.withWatch.rawValue {
                    sessionDelegate.toCall = {
                        self.sessionDelegate.toCall = self.play
                        DispatchQueue.main.async {
                        self.motionManager = CMMotionManager()
                        }
                    }
                }
                else if tv == TvSettings.withOutWatch.rawValue {
                    sessionDelegate.toCall = {}
                }
            }
        }
        
        //        Construct appropriate namefiles for selected chords
        var selectedChords = Array<String>()
        if let testChords = userDefault.array(forKey: USER_DEFAULT_KEY_STRING) {
            selectedChords = testChords as! Array<String>
        }
        else {
            print(userDefault.string(forKey: "PreferredNotation"));
            selectedChords = userDefault.string(forKey: "PreferredNotation") == "IT" ? ["La","La","La","La"] : ["A","A","A","A"];
        }
        toPlay = [String]()
        
        if userDefault.string(forKey: "PreferredNotation")! == "IT" {
            
            print(userDefault.string(forKey: "PreferredNotation")!);
            
            print("NOTAZIONE ITALIANA");
            
            toPlay.append(itaEnMap[selectedChords[0]]! + ".wav")
            toPlay.append(itaEnMap[selectedChords[1]]! + ".wav")
            toPlay.append(itaEnMap[selectedChords[2]]! + ".wav")
            toPlay.append(itaEnMap[selectedChords[3]]! + ".wav")
            
            print("ARRAY CHE CARICO = \(toPlay)")
            
        }
        else{
            
            print("NOTAZIONE INGLESE");
            
            toPlay.append(selectedChords[0] + ".wav")
            toPlay.append(selectedChords[1] + ".wav")
            toPlay.append(selectedChords[2] + ".wav")
            toPlay.append(selectedChords[3] + ".wav")
            
            print("ARRAY CHE CARICO = \(toPlay)");
        }
        
        //        Create guitars to play chords
        //        Il numero zero è associato al rosso e così via
        if let device = sessionTv.showConnectedDevices() {}
        else {
            do{
                guitar11 = try Guitar(file: toPlay[0])
                guitar21 = try Guitar(file: toPlay[1])
                guitar31 = try Guitar(file: toPlay[2])
                guitar41 = try Guitar(file: toPlay[3])
                guitar12 = try Guitar(file: toPlay[0])
                guitar22 = try Guitar(file: toPlay[1])
                guitar32 = try Guitar(file: toPlay[2])
                guitar42 = try Guitar(file: toPlay[3])
            }catch{
                print("Could not find guitar files")
            }
            
            //        create mixer, to allow repeated chords/multiple chords
            let mixer = AKMixer(guitar11?.chord, guitar21?.chord, guitar31?.chord, guitar41?.chord, guitar12?.chord, guitar22?.chord, guitar32?.chord, guitar42?.chord)
            AudioKit.output = mixer
            do{
                try AudioKit.start()
            }catch{
                print("Audiokit motor couldn't start!")
            }
        }
        
        
        let guitarSelected = UserDefaults.getGuitar(forKey: GUITAR)
        if guitarSelected == TypeOfGuitar.electric {
            motionManager.deviceMotionUpdateInterval = 0.3
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { data, error -> Void in
                if let data = data {
                    self.newAttitude = abs(data.attitude.roll)
                    
                    //0.50 radianti corrisponde a circa 30° -> Se il movimento avuto in 0.3 secondi è stato una rotazione di 30° rispetto alla vecchia posizione, rilevo un movimento buono
                    if self.newAttitude! > (self.oldAttitude + 0.50) || self.newAttitude! < (self.oldAttitude - 0.50) {
                        DispatchQueue.main.async {
                            if let device = self.sessionTv.showConnectedDevices() {
                                self.sessionTv.sendSignal(device[0], message: SignalCode.wah)
                            }
                        }
                    }
                    self.oldAttitude = self.newAttitude
                }
            })
        }
        
    }
    
    
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        try! AudioKit.stop()
        guitar11?.resetGuitar()
        guitar12?.resetGuitar()
        guitar21?.resetGuitar()
        guitar22?.resetGuitar()
        guitar31?.resetGuitar()
        guitar32?.resetGuitar()
        guitar41?.resetGuitar()
        guitar42?.resetGuitar()
        
        self.dismiss(animated: false, completion: nil)
        
        if sessionDelegate.session != nil {
            sessionDelegate.session.sendMessage(["payload": "stop"], replyHandler: nil, errorHandler: nil)
        }
        
        if let device = sessionTv.showConnectedDevices() {
            sessionTv.sendSignal(device[0], message: SignalCode.closeGame)
        }
        
    }
    
    
    var x = 0
    
    func play(){
        x += 1
        if self.redButton.isTouchInside {
            if !self.flag1{
                self.guitar11!.playGuitar()
                self.flag1 = true
            }
            else{
                self.guitar12!.playGuitar()
                self.flag1 = false
            }
        }
        
        if self.blueButton.isTouchInside {
            if !self.flag2{
                self.guitar21!.playGuitar()
                self.flag2 = true
            }
            else{
                self.guitar22!.playGuitar()
                self.flag2 = false
            }
        }
        
        if self.greenButton.isTouchInside {
            if !self.flag3{
                self.guitar31!.playGuitar()
                self.flag3 = true
            }
            else{
                self.guitar32!.playGuitar()
                self.flag3 = false
            }
        }
        
        if self.roseButton.isTouchInside {
            if !self.flag4{
                self.guitar41!.playGuitar()
                self.flag4 = true
            }
            else{
                self.guitar42!.playGuitar()
                self.flag4 = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let testUserDefault = userDefault.array(forKey: USER_DEFAULT_KEY_STRING) {
            var userData = testUserDefault as! Array<String>
            redButtonChord.text = userData[0]
            blueButtonChord.text = userData[1]
            greenButtonChord.text = userData[2]
            pinkButtonChord.text = userData[3]
        }
            
        else {
            let value = ["A","A","A","A"]
            userDefault.set(value, forKey: USER_DEFAULT_KEY_STRING)
            redButtonChord.text = "A"
            blueButtonChord.text = "A"
            greenButtonChord.text = "A"
            pinkButtonChord.text = "A"
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let sessionTv = SessionManager.share
        if let device = sessionTv.showConnectedDevices() {
            sessionTv.sendSignal(device[0], message: SignalCode.closeGame)
        }
    }
    
    
    @IBAction func touchUpInsideRed(_ sender: Any) {
        buttonActionRedInside!()
    }
    
    @IBAction func touchExitRed(_ sender: Any) {
        buttonActionRedExit!()
        
    }
    @IBAction func touchDownRed(_ sender: Any) {
        buttonActionRedDown!()
    }
    
    
    @IBAction func touchUpInsideBlue(_ sender: Any) {
        buttonActionBlueInside!()
    }
    
    @IBAction func touchExitBlue(_ sender: Any) {
        buttonActionBlueExit!()
    }
    @IBAction func touchDownBlue(_ sender: Any) {
        buttonActionBlueDown!()
    }
    
    
    @IBAction func touchUpInsideGreen(_ sender: Any) {
        buttonActionGreenInside!()
    }
    
    @IBAction func touchExitGreen(_ sender: Any) {
        buttonActionGreenExit!()
    }
    @IBAction func touchDownGreen(_ sender: Any) {
        buttonActionGreenDown!()
    }
    
    
    @IBAction func touchUpInsidePink(_ sender: Any) {
        buttonActionPinkInside!()
    }
    
    @IBAction func touchExitPink(_ sender: Any) {
        buttonActionPinkExit!()
        
    }
    @IBAction func touchDownPink(_ sender: Any) {
        buttonActionPinkDown!()
    }
}

extension GameModeViewController: SessionManagerDelegate {
    func peerFound(_ manger: SessionManager, peer: MCPeerID) {
        return
    }
    
    func nearPeerHasChangedState(_ manager: SessionManager, peer change: MCPeerID, connected: Int) {
        if connected == 0 {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func mexReceived(_ manager: SessionManager, didMessageReceived: SignalCode) {
        switch didMessageReceived {
        case .closeGamePhone:
            try! AudioKit.stop()
            guitar11?.resetGuitar()
            guitar12?.resetGuitar()
            guitar21?.resetGuitar()
            guitar22?.resetGuitar()
            guitar31?.resetGuitar()
            guitar32?.resetGuitar()
            guitar41?.resetGuitar()
            guitar42?.resetGuitar()
            
            DispatchQueue.main.async {
                self.dismiss(animated: false, completion: nil)
            }
        default:
            break
        }
    }
    
    func mexReceived(_ manager: SessionManager, didMessageReceived: Array<String>) {
        return
    }
    
    func peerLost(_ manager: SessionManager, peer lost: MCPeerID) {
        return
    }
}

extension GameModeViewController {
    func playRedInside() {
        DispatchQueue.main.async {
            self.sessionTv.sendSignal(self.device!, message: SignalCode.key1Released)
        }
    }
    
    func playRedExit() {
        DispatchQueue.main.async {
            self.sessionTv.sendSignal(self.device!, message: SignalCode.key1Released)
        }
    }
    
    func playRedDown() {
        DispatchQueue.main.async {
            self.sessionTv.sendSignal(self.device!, message: SignalCode.key1Pressed)
        }
    }
    
    func playBlueInside() {
        DispatchQueue.main.async {
            self.sessionTv.sendSignal(self.device!, message: SignalCode.key2Released)
        }
    }
    
    func playBlueExit() {
        DispatchQueue.main.async {
            self.sessionTv.sendSignal(self.device!, message: SignalCode.key2Released)
        }
    }
    
    func playBlueDown() {
        DispatchQueue.main.async {
            self.sessionTv.sendSignal(self.device!, message: SignalCode.key2Pressed)
        }
    }
    
    func playGreenInside() {
        DispatchQueue.main.async {
            self.sessionTv.sendSignal(self.device!, message: SignalCode.key3Released)
        }
    }
    
    func playGreenExit() {
        DispatchQueue.main.async {
            self.sessionTv.sendSignal(self.device!, message: SignalCode.key3Released)
        }
    }
    
    func playGreenDown() {
        DispatchQueue.main.async {
            self.sessionTv.sendSignal(self.device!, message: SignalCode.key3Pressed)
        }
    }
    
    func playPinkInside() {
        DispatchQueue.main.async {
            self.sessionTv.sendSignal(self.device!, message: SignalCode.key4Released)
        }
    }
    
    func playPinkExit() {
        DispatchQueue.main.async {
            self.sessionTv.sendSignal(self.device!, message: SignalCode.key4Released)
        }
    }
    
    func playPinkDown() {
        DispatchQueue.main.async {
            self.sessionTv.sendSignal(self.device!, message: SignalCode.key4Pressed)
        }
    }
    
    func playNothing() {
        return
    }
    
}
