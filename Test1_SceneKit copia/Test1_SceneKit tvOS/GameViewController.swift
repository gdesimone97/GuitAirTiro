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
    
    
    var button1: SCNNode!
    var button2: SCNNode!
    var button3: SCNNode!
    var button4: SCNNode!
    
    var guitar1: Guitar?
    var guitar2: Guitar?
    var guitar3: Guitar?
    var guitar4: Guitar?
    
    var playing: Bool = false
    var points: Int!
    
    let noteQueue = DispatchQueue(label: "noteQueue", qos: .userInteractive)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        
        session.delegate = self
        
        // Allow the user to manipulate the camera
        self.gameView.allowsCameraControl = false
        
        gameGuitarManager = GameGuitarManager(scene: gameView.scene!, width: 2.5, length: 20, z: -17)
        textManager = TextManager(scene: gameView.scene!)
        
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        var gestureRecognizers = gameView.gestureRecognizers ?? []
//        gestureRecognizers.insert(tapGesture, at: 0)
//        self.gameView.gestureRecognizers = gestureRecognizers
        
        addElements()
        
        do {
            guitar1 = try Guitar(file: "A.wav")
            guitar2 = try Guitar(file: "Am.wav")
            guitar3 = try Guitar(file: "B.wav")
            guitar4 = try Guitar(file: "Cm.wav")
        } catch {
            print("Could not find guitar files")
        }
        let mixer = AKMixer(guitar1?.chord, guitar2?.chord, guitar3?.chord, guitar4?.chord)
        AudioKit.output = mixer
        do{
            try AudioKit.start()
        }catch{
            print("Audiokit motor couldn't start!")
        }
        
        
        noteQueue.async {
            while self.playing == true {
                let rand = Int(random(in: 1...5))
                self.gameGuitarManager.showNode(column: rand)
                usleep(500000)
            }
        }
        
        playing = true
        points = 0
        
    }
    
//    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
//        guitar1?.playGuitar()
//        gameGuitarManager.showNode(column: 3)
//    }
    
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
                if self.gameGuitarManager.checkPoint(column: 1) {
                    self.points += 1
                }
                else {
                    self.points -= 1
                }
//                self.guitar1?.playGuitar()
                
            case .signal2:
                if self.gameGuitarManager.checkPoint(column: 2) {
                    self.points += 1
                }
                else {
                    self.points -= 1
                }
//                self.guitar2?.playGuitar()
                
            case .signal3:
                if self.gameGuitarManager.checkPoint(column: 3) {
                    self.points += 1
                }
                else {
                    self.points -= 1
                }
//                self.guitar3?.playGuitar()
                
            case .signal4:
                if self.gameGuitarManager.checkPoint(column: 4) {
                    self.points += 1
                }
                else {
                    self.points -= 1
                }
//                self.guitar4?.playGuitar()
                

            case .key1Pressed:
                self.button1.position.y = 0
            case .key2Pressed:
                self.button2.position.y = 0
            case .key3Pressed:
                self.button3.position.y = 0
            case .key4Pressed:
                self.button4.position.y = 0
                
            case .key1Released:
                self.button1.position.y = 0.1
            case .key2Released:
                self.button2.position.y = 0.1
            case .key3Released:
                self.button3.position.y = 0.1
            case .key4Released:
                self.button4.position.y = 0.1
                
                
                
            // Add more cases here
            default:
                break
            }
            
            print(self.points!)
        }
    }
    
}
