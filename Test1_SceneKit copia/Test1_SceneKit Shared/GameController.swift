//
//  File.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 30/07/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import SceneKit

class GameController: NSObject, SCNSceneRendererDelegate {
    
    let scene: SCNScene
    let sceneRenderer: SCNSceneRenderer
    
    init(sceneRenderer renderer: SCNSceneRenderer) {
        sceneRenderer = renderer
        scene = SCNScene(named: "Art.scnassets/GameScene.scn")!
        
        super.init()
        
        sceneRenderer.delegate = self
        sceneRenderer.scene = scene
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Called before each frame is rendered
    }
    
}
