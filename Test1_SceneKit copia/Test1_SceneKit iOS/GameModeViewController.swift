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

class GameModeViewController: UIViewController {
    
    var sessionDelegate: ViewController!
    let sessionTv = SessionManager.share
    
    
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
        redButtonChord?.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        blueButtonChord?.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        greenButtonChord?.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        pinkButtonChord?.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        
        if sessionDelegate != nil {
            if let device = sessionTv.showConncetedDevices() {
                let user = userDefault.integer(forKey: GAME_DEVICE_SETTINGS)
                if user == 0 {
                    sessionDelegate.toCall = {
                        self.sessionTv.sendSignal(device[0], message: SignalCode.signal)
                    }
                }
                else if user == 1 {
                    sessionDelegate.toCall = {}
                }
            }
                
            else {
                sessionDelegate.toCall = play
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
        if let device = sessionTv.showConncetedDevices() {}
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
        
        if sessionDelegate != nil{
            sessionDelegate.session.sendMessage(["payload": "stop"], replyHandler: nil, errorHandler: nil)
        }
    }
    
    
    var x = 0
    
    func play(){
        x += 1
        if self.redButton.isTouchInside {
            if !self.flag1{
                self.guitar11!.playGuitar() //stop and play
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
        if let device = sessionTv.showConncetedDevices() {
            sessionTv.sendSignal(device[0], message: SignalCode.closeGame)
        }
    }
    
    @IBAction func touchUpInsideRed(_ sender: Any) {
        if let device = sessionTv.showConncetedDevices() {
            sessionTv.sendSignal(device[0], message: SignalCode.key1Pressed)
        }
    }
    
    @IBAction func touchExitRed(_ sender: Any) {
        if let device = sessionTv.showConncetedDevices() {
            sessionTv.sendSignal(device[0], message: SignalCode.key1Released)
        }
        
    }
    @IBAction func touchDownRed(_ sender: Any) {
        if let device = sessionTv.showConncetedDevices() {
            sessionTv.sendSignal(device[0], message: SignalCode.key1Released)
        }
    }
}
