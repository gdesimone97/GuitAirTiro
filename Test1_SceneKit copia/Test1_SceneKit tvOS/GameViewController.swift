//
//  GameViewController.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 30/07/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import UIKit
import SceneKit


class GameViewController: UIViewController {
    
    var gameView: SCNView {
        return self.view as! SCNView
    }
    
    var gameController: GameController!
    var gameGuitarManager: GameGuitarManager!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        
        // Allow the user to manipulate the camera
        self.gameView.allowsCameraControl = false
        
        // Show statistics such as fps and timing information
        self.gameView.showsStatistics = true
        
        gameGuitarManager = GameGuitarManager(scene: gameView.scene!, width: 4, length: 10, z: -10)
        
        run()
    }
    
    func run() {
        gameGuitarManager.showNode(column: 1)
        gameGuitarManager.showNode(column: 2)
        gameGuitarManager.showNode(column: 3)
        gameGuitarManager.showNode(column: 4)
    }
    
}
