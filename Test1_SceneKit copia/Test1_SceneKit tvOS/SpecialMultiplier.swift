//
//  SpecialMultiplier.swift
//  Test1_SceneKit tvOS
//
//  Created by Gennaro Giaquinto on 28/08/2019.
//  Copyright © 2019 Gennaro Giaquinto. All rights reserved.
//

import Foundation
import SceneKit

class SpecialMultiplier {
    private let MIN: Float = 0
    private let MAX: Float = 1
    private let levelsNumber: Int = 5
    private var step: Float { return (MAX-MIN) / Float(levelsNumber) }
    
    private let scene: SCNScene
    private var levelNode: SCNNode
    private var actualLevel: Int = 0
    private var actualScale: Float = 0
    
    private var particleNode1: SCNNode!
    private var particleNode2: SCNNode!
    private let fireEffect = SCNParticleSystem(named: "Art.scnassets/Fire Effect/SceneKit Particle System.scnp", inDirectory: nil)
    
    private var empting: Bool = false
    private var toCall: (Bool)->Void
    
    init(scene: SCNScene, node: SCNNode, toCall: @escaping (Bool)->Void) {
        self.scene = scene
        self.levelNode = node
        self.toCall = toCall
    }
    
    func empty() {
        if actualLevel > 0 && !empting {
            empting = true
            toCall(true)
            startFire()
            DispatchQueue(label: "level").async {
                while self.actualScale >= 0.005 {
                    self.actualScale -= 0.005
                    self.levelNode.scale.y = self.actualScale
                    usleep(50000)
                }
                self.toCall(false)
                self.stopFire()
                self.empting = false
                self.actualLevel = 0
            }
        }
    }
    
    func fill() {
        if actualLevel != levelsNumber && !empting {
            actualLevel += 1
            let scale = Float(actualLevel) * step
            
            DispatchQueue(label: "level").async {
                while self.actualScale <= scale - 0.005 {
                    self.actualScale += 0.005
                    self.levelNode.scale.y = self.actualScale
                    usleep(30000)
                }
            }
        }
    }
    
    func startFire() {
        particleNode1 = SCNNode()
        particleNode2 = SCNNode()
        
        particleNode1.addParticleSystem(fireEffect!)
        particleNode2.addParticleSystem(fireEffect!)
        particleNode1.position = SCNVector3(-3.5, 0, -3)
        particleNode1.eulerAngles = SCNVector3(0, 0, -0.2)
        particleNode2.position = SCNVector3(3.5, 0, -3)
        particleNode2.eulerAngles = SCNVector3(0, 0, 0.2)
        
        self.scene.rootNode.addChildNode(particleNode1)
        self.scene.rootNode.addChildNode(particleNode2)
    }
    
    func stopFire() {
        particleNode1.removeFromParentNode()
        particleNode2.removeFromParentNode()
    }
    
}
