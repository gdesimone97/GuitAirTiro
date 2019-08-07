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


class GameViewController: UIViewController {
    
    var gameView: SCNView {
        return self.view as! SCNView
    }
    
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
        try! AudioKit.stop()
        playing = false
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
    
    var consecutivePoints: Int = 0
    var consecutiveFlag: Bool = false
    var points50: Bool = false
    var points100: Bool = false
    
    var playing: Bool = false
    var points = 0
    // I take the selected chords from the user defaults
    var chords: [String]!
    // I take the watch settings : true -> watch is present, false -> watch not present
    var watch: Bool!
    
    var pointText: SCNNode?
    var multiplierNode: SCNNode?
    var multiplier = 1
    
    var song: String! = Songs.PeppeGay.rawValue // Da settare dal telefono
    
    // This is the thread that shows nodes on the guitar
    let noteQueue = DispatchQueue(label: "noteQueue", qos: .userInteractive)
    let pointsQueue = DispatchQueue(label: "pointsQueue", qos: .userInteractive)
    let startQueue = DispatchQueue(label: "startQueue", qos: .userInteractive)
    let stateQueue = DispatchQueue(label: "stateQueue", qos: .userInteractive)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        
        session.delegate = self
        
        gameGuitarManager = GameGuitarManager(scene: gameView.scene!, width: 2.5, length: 20, z: -17, function: changePoints(p:consecutive:))
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
            var startNode: SCNNode!
            DispatchQueue.main.async {
                startNode = self.textManager.addTextAtPosition(str: "Press the button on the remote to start!", x: -2, y: 3, z: 0)
                startNode.eulerAngles = SCNVector3(0.1, 0, 0)
            }
            self.semaphoreStart.wait()
            startNode.removeFromParentNode()
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
            
            // Called 3 times to unlock all the 3 threads waiting
            self.semaphorePlay.signal()
            self.semaphorePlay.signal()
            self.semaphorePlay.signal()
        }
        
        
        pointsQueue.async {
            self.semaphorePlay.wait()
            while self.playing == true {
                self.updatePoints()
                usleep(100000)
            }
        }
        
        noteQueue.async {
            // This thread shows the buttons to play while gaming.
            self.semaphorePlay.wait()
            while self.playing == true {
                for pair in self.song.split(separator: ";") {
                    let x = pair.split(separator: ":")
                    for i in 0..<x.count-1 {
                        self.gameGuitarManager.showNode(column: Int(x[i])!)
                    }
                    
                    usleep(UInt32(x[x.count-1])!)
                }
                
            }
        }
        
        stateQueue.async {
            self.semaphorePlay.wait()
            while self.playing == true {
                if !self.points50 && self.points > 50 {
                    self.textManager.addGameNotification(str: "Wow! 50 points!", color: UIColor.white, duration: 2)
                    self.gameGuitarManager.fire()
                    self.points50 = true
                }
                if !self.points100 && self.points > 100 {
                    self.textManager.addGameNotification(str: "You are a legend!", color: UIColor.white, duration: 2)
                    self.gameGuitarManager.fire()
                    self.points100 = true
                }
            }
        }
        
    }
    
    // Function started only if watch is not present
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        if watch {
            gameGuitarManager.fire()
        }
        else {
            var flag = false
            if button1Pressed {
                play(col: 1)
                if self.gameGuitarManager.checkPoint(column: 1) {
                    points += multiplier
                }
                else {
                    points -= 1
                }
                flag = true
            }
            if button2Pressed {
                play(col: 2)
                if self.gameGuitarManager.checkPoint(column: 2) {
                    points += multiplier
                }
                else {
                    points -= 1
                }
                flag = true
            }
            if button3Pressed {
                play(col: 3)
                if self.gameGuitarManager.checkPoint(column: 3) {
                    points += multiplier
                }
                else {
                    points -= 1
                }
                flag = true
            }
            if button4Pressed {
                play(col: 4)
                if self.gameGuitarManager.checkPoint(column: 4) {
                    points += multiplier
                }
                else {
                    points -= 1
                }
                flag = true
            }
            
            if !flag {
                points -= 1
            }
        }
        
        if !playing {
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
            self.pointText = self.textManager.addTextAtPosition(str: "Points: \(self.points )", x: 1.5, y: 3.3, z: -0.5)
            self.pointText?.eulerAngles = SCNVector3(x: 0, y: -0.15, z: 0)
            
            self.multiplierNode = self.textManager.addTextAtPosition(str: "Multiplier: x\(self.multiplier)", x: 1.5, y: 3, z: -0.5)
            self.multiplierNode?.eulerAngles = SCNVector3(x: 0, y: -0.15, z: 0)
        }
    }
    
    func changePoints(p: Int, consecutive: Bool) {
        points += p
        consecutiveFlag = consecutive
        if consecutive {
            consecutivePoints += 1
        }
        else {
            consecutivePoints = 0
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
                    if self.gameGuitarManager.checkPoint(column: 1) {
                        self.points += self.multiplier
                    }
                    else {
                        self.points -= self.multiplier
                    }
                }
                if self.button2Pressed {
                    self.play(col: 2)
                    if self.gameGuitarManager.checkPoint(column: 2) {
                        self.points += self.multiplier
                    }
                    else {
                        self.points -= self.multiplier
                    }
                }
                if self.button3Pressed {
                    self.play(col: 3)
                    if self.gameGuitarManager.checkPoint(column: 3) {
                        self.points += self.multiplier
                    }
                    else {
                        self.points -= self.multiplier
                    }
                }
                if self.button4Pressed {
                    self.play(col: 4)
                    if self.gameGuitarManager.checkPoint(column: 4) {
                        self.points += self.multiplier
                    }
                    else {
                        self.points -= self.multiplier
                    }
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
