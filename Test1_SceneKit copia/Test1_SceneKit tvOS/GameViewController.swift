//
//  GameViewController.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 30/07/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit
import SceneKit
import MultipeerConnectivity
import AudioKit
import GameController

protocol ReactToMotionEvents {
    func motionUpdate(motion: GCMotion) -> Void
}


class GameViewController: UIViewController {
    
    var gameView: SCNView {
        return self.view as! SCNView
    }
    
    var motionDelegate: ReactToMotionEvents?
    
    var gameController: GameController!
    var gameGuitarManager: GameGuitarManager!
    var textManager: TextManager!
    var soundEffect: SoundEffect!
    
    var session = SessionManager.share
    var dictionary: DeviceDictionary!
    
    let semaphoreStart = DispatchSemaphore(value: 0)
    let semaphorePlay = DispatchSemaphore(value: 0)
    
    // This closure is used for setting the Session Delegate when the this View is dismissed
    // It is setted by the View that opens this view
    var callbackClosure: ( () -> Void )?
    
    override func viewWillDisappear(_ animated: Bool) {
        sendSignalWhenClosing()
        soundEffect.stopGuitars()
        self.playing = false
        callbackClosure?()
    }
    
    var button1: SCNNode!
    var button2: SCNNode!
    var button3: SCNNode!
    var button4: SCNNode!
    
    var button1Pressed: Bool = false
    var button2Pressed: Bool = false
    var button3Pressed: Bool = false
    var button4Pressed: Bool = false
    
    var goodNote: Bool = false
    var movedController: Bool = false
    
    var consecutivePoints: Int = 0
    var points50: Bool = false
    var points100: Bool = false
    
    var playing: Bool = false
    var points = 0
    // I take the selected chords from the user defaults
    var chords: [String]!
    // I take the watch settings : true -> watch is present, false -> watch not present
    var watch: Bool!
    
    var startNode: SCNNode?
    var pointText: SCNNode?
    var multiplierNode: SCNNode?
    var multiplier = 1
    
    var song: String! = Songs.LaCanzoneDelSole.rawValue // Da settare dal telefono
    
    // This is the thread that shows nodes on the guitar
    let noteQueue = DispatchQueue(label: "noteQueue", qos: .userInteractive)
    let pointsQueue = DispatchQueue(label: "pointsQueue", qos: .userInteractive)
    let startQueue = DispatchQueue(label: "startQueue", qos: .userInteractive)
    
    
    var soundThreshold = 2.0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        
        session.delegate = self
        
        gameGuitarManager = GameGuitarManager(scene: gameView.scene!, width: 2.5, length: 20, z: -17, function: changePoints(point:))
        textManager = TextManager(scene: gameView.scene!)
        soundEffect = SoundEffect(file1: chords[0], file2: chords[1], file3: chords[2], file4: chords[3])
        
        
        // Allow the tapGesture on the remote
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        var gestureRecognizers = gameView.gestureRecognizers ?? []
        gestureRecognizers.insert(tapGesture, at: 0)
        self.gameView.gestureRecognizers = gestureRecognizers
        
        addElements()
        
        startQueue.async {
            sleep(1)
            self.points = 0
            DispatchQueue.main.async {
                self.startNode = self.textManager.addTextAtPosition(str: "Press the button on the remote to start!", x: -2, y: 3, z: 0)
                self.startNode!.eulerAngles = SCNVector3(0.1, 0, 0)
            }
            self.semaphoreStart.wait()
            self.startNode!.removeFromParentNode()
            self.soundEffect.countdown()
            self.textManager.addGameNotification(str: "3", color: UIColor.white, duration: 0.5)
            sleep(1)
            self.textManager.addGameNotification(str: "2", color: UIColor.white, duration: 0.5)
            sleep(1)
            self.textManager.addGameNotification(str: "1", color: UIColor.white, duration: 0.5)
            sleep(1)
            self.textManager.addGameNotification(str: "GO!", color: UIColor.white, duration: 0.5)
            sleep(1)
            self.playing = true
            
            // Called 2 times to unlock all the 2 threads waiting
            self.semaphorePlay.signal()
            self.semaphorePlay.signal()
        }
        
        
        pointsQueue.async {
            self.semaphorePlay.wait()
            while self.playing {
                self.updatePoints()
                usleep(100000)
            }
        }
        
        noteQueue.async {
            // This thread shows the notes to play taking the song's string
            self.semaphorePlay.wait()
            for pair in self.song.split(separator: ";") {
                let x = pair.split(separator: ":")
                for i in 0..<x.count-1 {
                    self.gameGuitarManager.showNode(column: Int(x[i])!)
                }
                
                usleep(UInt32(x[x.count-1])!)
            }
            
            sleep(3)
            
            if self.playing {
                // when the song stops
                sleep(2)
                self.motionDelegate = nil
                self.soundEffect.applauseSound()
                if self.points > 0 {
                    self.textManager.addGameNotification(str: "You did \(self.points) points!", color: UIColor.white, duration: 3)
                }
                else {
                    self.textManager.addGameNotification(str: "Oh, you did 0 points...", color: UIColor.white, duration: 3)
                }
                
                self.gameGuitarManager.fire()
                sleep(4)
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
        
        // Setto il motionDelegate del controller
        motionDelegate = self
        
    }
    
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        if playing && watch {
            gameGuitarManager.fire()
        }
        else if playing && !watch { // PROVVISORIO SI PUò TOGLIERE SE FUNZIONA L'ACCELEROMETRO
        }
        
        if !playing && startNode != nil {
            //Cerco tra i controller disponibili, il Remote
            let controllers = GCController.controllers()
            for controller in controllers {
                if controller.vendorName! == "Remote" {
                    // Setto l'handler, ovvero il blocco che verrà eseguito ogni volta che un valore qualsiasi del controller cambia
                    controller.motion?.valueChangedHandler = { (motion: GCMotion)->() in
                        if let delegate = self.motionDelegate {
                            delegate.motionUpdate(motion: motion)
                        }
                    }
                }
            }
            semaphoreStart.signal()
            
        }
    }
    
    
    func addElements() {
        let node = self.gameView.scene!.rootNode.childNode(withName: "nodes", recursively: false)
        self.gameView.scene!.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "button1" {
                button1 = node
            }
            if node.name == "button2" {
                button2 = node
            }
            if node.name == "button3" {
                button3 = node
            }
            if node.name == "button4" {
                button4 = node
            }
        }
    }
    
    
    
    func play(col: Int){
        
        DispatchQueue.main.async {
            switch col {
            case 1:
                self.soundEffect.guitar1()
                
            case 2:
                self.soundEffect.guitar2()
                
            case 3:
                self.soundEffect.guitar3()
                
            case 4:
               self.soundEffect.guitar4()
                
            default:
                break
            }
        }
    }
    
    func updatePoints() {
        DispatchQueue.main.async {
            if let node = self.pointText {
                node.removeFromParentNode()
            }
            if let node = self.multiplierNode {
                node.removeFromParentNode()
            }
            self.pointText = self.textManager.addTextAtPosition(str: "Points: " + (self.points > 0 ? String(self.points) : "0"), x: 1.5, y: 3.3, z: -0.5)
            self.pointText?.eulerAngles = SCNVector3(x: 0, y: -0.15, z: 0)
            
            self.multiplierNode = self.textManager.addTextAtPosition(str: "Multiplier: x\(self.multiplier)", x: 1.5, y: 3, z: -0.5)
            self.multiplierNode?.eulerAngles = SCNVector3(x: 0, y: -0.15, z: 0)
        }
    }
    
    func changePoints(point: Bool) {
        if !self.playing {
            return
        }
        
        if point {
            if self.points < 0 {
                self.points = 1
            }
            else {
                self.points += multiplier
            }
        }
        else {
            points -= 1
        }
        
        if self.points < -5 {
            DispatchQueue(label: "failed", qos: .userInteractive).async {
                self.playing = false
                self.motionDelegate = nil
                self.soundEffect.booSound()
                self.textManager.addGameNotification(str: "You failed!", color: UIColor.red, duration: 3)
                sleep(4)
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
        
        
        if point {
            consecutivePoints += 1
        }
        else {
            consecutivePoints = 0
        }
        
        if !points50 && points > 50 {
            textManager.addGameNotification(str: "Wow! 50 points!", color: UIColor.white, duration: 2)
            gameGuitarManager.fire()
            points50 = true
        }
        if !points100 && points > 100 {
            textManager.addGameNotification(str: "You are a legend!", color: UIColor.white, duration: 2)
            gameGuitarManager.fire()
            points100 = true
        }
        
        switch consecutivePoints {
        case 0:
            multiplier = 1
        case 10:
            multiplier = 2
            textManager.addGameNotification(str: "Wow! 10 consecutive notes!", color: UIColor.white, duration: 2)
            gameGuitarManager.fire()
        case 20:
            multiplier = 3
            textManager.addGameNotification(str: "Amazing! 20 consecutive notes!", color: UIColor.white, duration: 2)
            gameGuitarManager.fire()
        case 30:
            multiplier = 4
            textManager.addGameNotification(str: "Impressive! 30 consecutive notes!", color: UIColor.white, duration: 2)
            gameGuitarManager.fire()
        case 40:
            multiplier = 5
            textManager.addGameNotification(str: "Perfect! 40 consecutive notes!", color: UIColor.white, duration: 2)
            gameGuitarManager.fire()
        default:
            break
        }
    }
    
    
    func sendSignalWhenClosing() {
        if let device = session.showConnectedDevices() {
            session.sendSignal(device[0], message: SignalCode.closeGamePhone)
        }
    }
    
    
}

extension GameViewController: SessionManagerDelegate {
    
    func peerFound(_ manger: SessionManager, peer: MCPeerID) {
        dictionary.addSample(peer: peer)
    }
    
    func peerLost(_ manager: SessionManager, peer lost: MCPeerID) {
        dictionary.removeSample(peer: lost)
    }
    
    
    func nearPeerHasChangedState(_ manager: SessionManager, peer change: MCPeerID, connected: Int) {
        DispatchQueue.main.async {
            if connected == 0 {
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: nil)
                }
            }
        }
    }
    
    func mexReceived(_ manager: SessionManager, didMessageReceived: Array<String>) {
        
    }
    
    func mexReceived(_ manager: SessionManager, didMessageReceived: SignalCode) {
        DispatchQueue.main.async {
            
            switch didMessageReceived {
            
            case .closeGame: // Stop the game session
                self.dismiss(animated: false, completion: nil)
            
            case .signal:
                if self.button1Pressed {
                    self.play(col: 1)
                    self.gameGuitarManager.checkPoint(column: 1)
                }
                if self.button2Pressed {
                    self.play(col: 2)
                    self.gameGuitarManager.checkPoint(column: 2)
                }
                if self.button3Pressed {
                    self.play(col: 3)
                    self.gameGuitarManager.checkPoint(column: 3)
                }
                if self.button4Pressed {
                    self.play(col: 4)
                    self.gameGuitarManager.checkPoint(column: 4)
                }
                

            case .key1Pressed:
                self.button1.position.y = 0
                self.button1Pressed = true
            case .key2Pressed:
                self.button2.position.y = 0
                self.button2Pressed = true
            case .key3Pressed:
                self.button3.position.y = 0
                self.button3Pressed = true
            case .key4Pressed:
                self.button4.position.y = 0
                self.button4Pressed = true
                
            case .key1Released:
                self.button1.position.y = 0.1
                self.button1Pressed = false
            case .key2Released:
                self.button2.position.y = 0.1
                self.button2Pressed = false
            case .key3Released:
                self.button3.position.y = 0.1
                self.button3Pressed = false
            case .key4Released:
                self.button4.position.y = 0.1
                self.button4Pressed = false
                
                
                
            // Add more cases here
            default:
                break
            }
        }
    }
}

extension GameViewController: ReactToMotionEvents {
    
    func motionUpdate(motion: GCMotion) {
        
        let motionAcceleration = motion.userAcceleration.y * motion.gravity.y + motion.userAcceleration.x * motion.gravity.x + motion.userAcceleration.z * motion.gravity.z
        
        
        if !movedController && -motionAcceleration > soundThreshold {
            
            movedController = true
            goodNote = false
            
            if button1Pressed {
                play(col: 1)
                self.gameGuitarManager.checkPoint(column: 1)
                goodNote = true
            }
            if button2Pressed {
                play(col: 2)
                self.gameGuitarManager.checkPoint(column: 2)
                goodNote = true
            }
            if button3Pressed {
                play(col: 3)
                self.gameGuitarManager.checkPoint(column: 3)
                goodNote = true
            }
            if button4Pressed {
                play(col: 4)
                self.gameGuitarManager.checkPoint(column: 4)
                goodNote = true
            }
            
            if !goodNote {
                changePoints(point: false)
            }
        }
        
        if movedController && motionAcceleration > 1.50  {
            movedController = false
        }
        
    }
}
