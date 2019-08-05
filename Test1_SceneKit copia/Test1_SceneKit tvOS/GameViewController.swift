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
    
    var session = SessionManager.share
    
    
    // This closure is used for setting the Session Delegate when the this View is dismissed
    // It is setted by the View that opens this view
    var callbackClosure: ( () -> Void )?
    
    override func viewWillDisappear(_ animated: Bool) {
        try! AudioKit.stop()
        playing = false
        callbackClosure?()
    }
    
    var chords: [String]!
    
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
    
    var button1: SCNNode!
    var button2: SCNNode!
    var button3: SCNNode!
    var button4: SCNNode!
    
    var button1Pressed: Bool = false
    var button2Pressed: Bool = false
    var button3Pressed: Bool = false
    var button4Pressed: Bool = false
    
    var playing: Bool = false
    var points: Int!
    var watch: Bool! // true -> watch is present, false -> watch not present
    
    let noteQueue = DispatchQueue(label: "noteQueue", qos: .userInteractive)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        
        session.delegate = self
        
        // Allow the user to manipulate the camera
        self.gameView.allowsCameraControl = false
        
        gameGuitarManager = GameGuitarManager(scene: gameView.scene!, width: 2.5, length: 20, z: -17)
        textManager = TextManager(scene: gameView.scene!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        var gestureRecognizers = gameView.gestureRecognizers ?? []
        gestureRecognizers.insert(tapGesture, at: 0)
        self.gameView.gestureRecognizers = gestureRecognizers
        
        addElements()
        
        
        noteQueue.async {
            // This thread shows the buttons to play while gaming.
            while self.playing == true {
                let rand = Int(random(in: 1...5))
                self.gameGuitarManager.showNode(column: rand)
                usleep(500000)
            }
        }
        
        playing = true
        points = 0
        
    }
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        if watch {
            gameGuitarManager.fire()
            textManager.addGameNotification(str: "Mario è GAY!", color: UIColor.red)
        }
        else {
            if button1Pressed {
                self.gameGuitarManager.checkPoint(column: 1)
            }
            if button2Pressed {
                self.gameGuitarManager.checkPoint(column: 2)
            }
            if button3Pressed {
                self.gameGuitarManager.checkPoint(column: 3)
            }
            if button4Pressed {
                self.gameGuitarManager.checkPoint(column: 4)
            }
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
    
    
    func initAudioKit(file1: String, file2: String, file3: String, file4: String) {
        do{
            guitar11 = try Guitar(file: file1)
            guitar21 = try Guitar(file: file2)
            guitar31 = try Guitar(file: file3)
            guitar41 = try Guitar(file: file4)
            guitar12 = try Guitar(file: file1)
            guitar22 = try Guitar(file: file2)
            guitar32 = try Guitar(file: file3)
            guitar42 = try Guitar(file: file4)
        }catch{
            print("Could not find guitar files")
        }
        
        // create mixer, to allow repeated chords/multiple chords
        let mixer = AKMixer(guitar11?.chord, guitar21?.chord, guitar31?.chord, guitar41?.chord, guitar12?.chord, guitar22?.chord, guitar32?.chord, guitar42?.chord)
        AudioKit.output = mixer
        do{
            try AudioKit.start()
        }catch{
            print("Audiokit motor couldn't start!")
        }
        
    }
    
    
}

extension GameViewController: SessionManagerDelegate {
    func peerFound(_ manger: SessionManager, peer: MCPeerID) {
    }
    
    func peerLost(_ manager: SessionManager, peer lost: MCPeerID) {
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
    
    func mexReceived(_ manager: SessionManager, didMessageReceived: SignalCode) {
        DispatchQueue.main.async {
            
            switch didMessageReceived {
            
            case .closeGame: // Stop the game session
                self.dismiss(animated: false, completion: nil)
            
            case .signal1:
                //                self.guitar1?.playGuitar()
                if self.gameGuitarManager.checkPoint(column: 1) {
                    self.points += 1
                }
                else {
                    self.points -= 1
                }
                
            case .signal2:
                //                self.guitar2?.playGuitar()
                if self.gameGuitarManager.checkPoint(column: 2) {
                    self.points += 1
                }
                else {
                    self.points -= 1
                }
                
            case .signal3:
                //                self.guitar3?.playGuitar()
                if self.gameGuitarManager.checkPoint(column: 3) {
                    self.points += 1
                }
                else {
                    self.points -= 1
                }
                
            case .signal4:
                //                self.guitar4?.playGuitar()
                if self.gameGuitarManager.checkPoint(column: 4) {
                    self.points += 1
                }
                else {
                    self.points -= 1
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
            
            print(self.points!)
        }
    }
    
}
