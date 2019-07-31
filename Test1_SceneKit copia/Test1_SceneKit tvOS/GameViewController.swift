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


class GameViewController: UIViewController {
    
    var gameView: SCNView {
        return self.view as! SCNView
    }
    
    var gameController: GameController!
    var gameGuitarManager: GameGuitarManager!
    
    var session = SessionManager.share


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        
        session.delegate = self
        
        // Allow the user to manipulate the camera
        self.gameView.allowsCameraControl = false
        
        // Show statistics such as fps and timing information
        self.gameView.showsStatistics = true
        
        gameGuitarManager = GameGuitarManager(scene: gameView.scene!, width: 4, length: 20, z: -17)
        
    }
    
}

extension GameViewController: SessionManagerDelegate {
    
    func peerLost(_ manager: SessionManager, peer lost: MCPeerID) {
    }
    
    func peerFound(_ manger: SessionManager, peer: MCPeerID) {
    }
    
    
    func nearPeerHasChangedState(_ manager: SessionManager, peer change: MCPeerID, connected: Int) {
        
    }
    
    func mexReceived(_ manager: SessionManager, didMessageReceived: SignalCode) {
        switch didMessageReceived {
        case .closeGame: // Stop the game session
            performSegue(withIdentifier: "MainSegue", sender: nil)
        case .note1: // Box in col1
            gameGuitarManager.showNode(column: 1)
        case .note2: // Box in col2
            gameGuitarManager.showNode(column: 2)
        case .note3: // Box in col3
            gameGuitarManager.showNode(column: 3)
        case .note4: // Box in col4
            gameGuitarManager.showNode(column: 4)
            
            
        // Add more cases here
        default:
            break
        }
    }
    
}
