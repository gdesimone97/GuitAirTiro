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
    
    var session = SessionManager.share
    
    // This closure is used for setting the Session Delegate when the this View is dismissed
    // It is setted by the View that opens this view
    var callbackClosure: ( () -> Void )?
    
    override func viewWillDisappear(_ animated: Bool) {
        try! AudioKit.stop()
        callbackClosure?()
    }
    
    
    var button1: SCNPlane!
    var button2: SCNNode!
    var button3: SCNNode!
    var button4: SCNNode!
    
    
    var guitar1: Guitar?
    var guitar2: Guitar?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        
        session.delegate = self
        
        // Allow the user to manipulate the camera
        self.gameView.allowsCameraControl = false
        
        gameGuitarManager = GameGuitarManager(scene: gameView.scene!, width: 2.5, length: 20, z: -17)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        var gestureRecognizers = gameView.gestureRecognizers ?? []
        gestureRecognizers.insert(tapGesture, at: 0)
        self.gameView.gestureRecognizers = gestureRecognizers
        
        addElements()
        
        do {
            guitar1 = try Guitar(file: "A.wav")
            guitar2 = try Guitar(file: "Am.wav")
        } catch {
            print("Could not find guitar files")
        }
        let mixer = AKMixer(guitar1?.chord, guitar2?.chord)
        AudioKit.output = mixer
        do{
            try AudioKit.start()
        }catch{
            print("Audiokit motor couldn't start!")
        }
        
    }
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        guitar1?.playGuitar()
        gameGuitarManager.showNode(column: 3)
    }
    
    func addElements() {
        let node = self.gameView.scene!.rootNode.childNode(withName: "planes", recursively: false)
        self.gameView.scene!.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "plane1" {
                button1 = node
            }
            if node.name == "plane2" {
                button2 = node
            }
            if node.name == "plane3" {
                button3 = node
            }
            if node.name == "plane4" {
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
        switch didMessageReceived {
		
        case .closeGame: // Stop the game session
            DispatchQueue.main.async {
                self.dismiss(animated: false, completion: nil)
            }
        case .note1: // Box in col1
            guitar1?.playGuitar()
        case .note2: // Box in col2
            guitar2?.playGuitar()
        case .note3: // Box in col3
            gameGuitarManager.showNode(column: 3)
        case .note4: // Box in col4
            gameGuitarManager.showNode(column: 4)
        case .key1Pressed:
            
        case .key2Pressed:
            button2.firstMaterial?.metalness = 0
        case .key3Pressed:
            button3.firstMaterial?.metalness = 0
        case .key4Pressed:
            button4.firstMaterial?.metalness = 0
        case .key1Released:
            button1.firstMaterial?.metalness = 1
        case .key2Released:
            button1.firstMaterial?.metalness = 1
        case .key3Released:
            button1.firstMaterial?.metalness = 1
        case .key4Released:
            button1.firstMaterial?.metalness = 1
            
            
            
        // Add more cases here
        default:
            break
        }
    }
    
}
