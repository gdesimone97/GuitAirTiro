//
//  GameController.swift
//  Test1_SceneKit Shared
//
//  Created by Gennaro Giaquinto on 24/07/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import SceneKit

#if os(watchOS)
    import WatchKit
#endif

#if os(macOS)
    typealias SCNColor = NSColor
#else
    typealias SCNColor = UIColor
#endif

class MainController: NSObject, SCNSceneRendererDelegate {

    let scene: SCNScene
    let sceneRenderer: SCNSceneRenderer
    
    init(sceneRenderer renderer: SCNSceneRenderer) {
        sceneRenderer = renderer
        scene = SCNScene(named: "Art.scnassets/MainScene.scn")!
        
        super.init()
        
        sceneRenderer.delegate = self
        sceneRenderer.scene = scene
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Called before each frame is rendered
    }

}
