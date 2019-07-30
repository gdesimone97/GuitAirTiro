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


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        
        // Allow the user to manipulate the camera
        self.gameView.allowsCameraControl = false
        
        // Show statistics such as fps and timing information
        self.gameView.showsStatistics = true
        
        self.addContent()
    }
    
    func addContent() {
        let node = self.gameView.scene!.rootNode.childNode(withName: "Node", recursively: false)
        self.gameView.scene!.rootNode.enumerateChildNodes { (node, _) in
            if node.name == "box" {
                
            }
        }
    }
    
}
